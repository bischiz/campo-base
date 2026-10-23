import 'package:campo_base/data/model/partecipantModel.dart';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:campo_base/data/model/eventModel.dart';
import 'package:campo_base/data/repository/authRepository.dart'; // Import necessario

class EventsPageData {
  final List<EventModel> pastEvents;
  final List<EventModel> officialEvents;
  final Set<DateTime> eventDates;

  EventsPageData({
    required this.pastEvents,
    required this.officialEvents,
    required this.eventDates,
  });
}

class EventiRepository {
  final PocketBase _pb;
  final AuthRepository _authRepository; // Nuova dipendenza

  EventiRepository({required PocketBase pb, required AuthRepository authRepository}) 
      : _pb = pb,
        _authRepository = authRepository;

  Future<EventsPageData> fetchAllEventsData(String userId) async {
    try {
      // 1. Carichiamo tutti gli eventi E le iscrizioni dell'utente in parallelo
      final results = await Future.wait([
        _pb.collection('events').getFullList(),
        _pb.collection('iscrizioni').getFullList(filter: 'utente="$userId"'),
      ]);

      final allEventRecords = results[0];
      final userSubscriptions = results[1];

      // Creiamo un Set di ID per un controllo super-veloce
      final subscribedEventIds = userSubscriptions.map((sub) => sub.getStringValue('evento')).toSet();

      final now = DateTime.now();
      final List<EventModel> pastEvents = [];
      final List<EventModel> officialEvents = [];
      final Set<DateTime> eventDates = {};

      // 2. Filtriamo i risultati in Dart
      for (var record in allEventRecords) {
        // Controlla se l'ID di questo evento è nel Set delle iscrizioni
        final isSubscribed = subscribedEventIds.contains(record.id);

        final event = EventModel.fromRecordModel(record, isSubscribed, _pb);

        if (event.date.isBefore(now)) {
          pastEvents.add(event);
        } else {
          officialEvents.add(event);
          eventDates.add(DateTime(event.date.year, event.date.month, event.date.day));
        }
      }

      // 3. Riordiniamo le liste per data
      pastEvents.sort((a, b) => b.date.compareTo(a.date)); // Passati: dal più recente
      officialEvents.sort((a, b) => a.date.compareTo(b.date)); // Ufficiali: dal più vicino

      return EventsPageData(
        pastEvents: pastEvents,
        officialEvents: officialEvents,
        eventDates: eventDates,
      );
    } catch (e) {
      print('Errore in fetchAllEventsData: $e');
      rethrow;
    }
  }

  Future<List<ParticipantModel>> getParticipants(String eventId) async {
    try {
      final records = await _pb.collection('iscrizioni').getFullList(
            filter: 'evento="$eventId"',
            expand: 'utente',
          );

      // Recuperiamo la lista bloccati dalla cache
      final blockedIds = _authRepository.blockedUserIds;

      //debugPrint('Partecipanti caricati: $records');

      return records.map((record) {
        final userRecord = record.expand['utente']!.first;
        
        // CHECK BLOCCATI: Se l'utente è bloccato, restituiamo il placeholder
        if (blockedIds.contains(userRecord.id)) {
           return ParticipantModel.returnBlockedUser();
        }

        return ParticipantModel.fromUserRecord(userRecord, _pb);
      }).toList();
    } catch (e) {
      print('Errore caricamento partecipanti: $e');
      rethrow;
    }
  }

  Future<void> subscribeToEvent(String eventId, String userId) async {
    final body = <String, dynamic>{"utente": userId, "evento": eventId};
    await _pb.collection('iscrizioni').create(body: body);
  }

  Future<void> unsubscribeFromEvent(String eventId, String userId) async {
    try {
      final record = await _pb.collection('iscrizioni').getFirstListItem('utente="$userId" && evento="$eventId"');
      await _pb.collection('iscrizioni').delete(record.id);
    } catch (e) {
      rethrow;
    }
  }

  // AGGIUNGI QUESTO METODO
  Future<EventModel> getEventById(String eventId, String userId) async {
    try {
      // 1. Scarica l'evento
      final record = await _pb.collection('events').getOne(eventId);

      // 2. Controlla se l'utente è iscritto (per avere il campo isSubscribed corretto)
      bool isSubscribed = false;
      try {
        await _pb.collection('iscrizioni').getFirstListItem('utente="$userId" && evento="$eventId"');
        isSubscribed = true;
      } catch (_) {
        isSubscribed = false;
      }

      // 3. Ritorna il modello completo
      return EventModel.fromRecordModel(record, isSubscribed, _pb);
    } catch (e) {
      rethrow;
    }
  }
  // ... (getParticipants, getComments, ecc.)
}