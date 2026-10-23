import 'package:campo_base/data/model/cardable.dart';
import 'package:equatable/equatable.dart';
import 'package:pocketbase/pocketbase.dart';

class EventModel extends Equatable implements ICardable {
  final String title;
  final String description;
  final DateTime date;
  final String place;
  final String difficulty;
  final List<dynamic> requirements;
  final String id;
  final bool iscritto;
  final String image;
  final String organizzatore;
  final String linkgruppo;
  final bool iscrizioniAperte;

  const EventModel({
    required this.title,
    required this.description,
    required this.date,
    required this.place,
    required this.difficulty,
    required this.requirements,
    required this.id,
    required this.iscritto,
    required this.image,
    required this.organizzatore,
    required this.linkgruppo,
    required this.iscrizioniAperte,
  });

  String getNaturalDate() {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  factory EventModel.fromRecordModel(RecordModel record, bool iscritto, PocketBase pb) {
    String imageUrl = "https://via.placeholder.com/150";
    final imageFilename = record.getStringValue('image');

    if (imageFilename.isNotEmpty) {
      imageUrl = pb.getFileUrl(record, imageFilename).toString();
    }

    List<dynamic> requirementsList = []; // Default: lista vuota
    try {
      // 1. Prendi l'intero oggetto JSON dal campo 'requirements'
      // Assicurati che il nome 'requirements' sia corretto
      final jsonField = record.getDataValue<Map<String, dynamic>>('requirements');

      // 2. Controlla che non sia nullo e che contenga la chiave 'array'
      if (jsonField.containsKey('array') && jsonField['array'] is List) {
        requirementsList = jsonField['array'] as List<dynamic>;
      }
    } catch (e) {
      print('Errore parsing requisiti: $e');
      // Lascia la lista vuota in caso di errore
    }

    return EventModel(
      title: record.getStringValue('title'),
      description: record.getStringValue('description'),
      date: DateTime.parse(record.getStringValue('date')),
      place: record.getStringValue('place'),
      difficulty: record.getStringValue('difficulty'),
      requirements: requirementsList, // Modo più sicuro di prendere le liste
      id: record.id,
      iscritto: iscritto,
      organizzatore: record.getStringValue('organizzatore'),
      linkgruppo: record.getStringValue('link_wp'),
      iscrizioniAperte: record.getBoolValue('iscrizioni_aperte'),
      image: imageUrl,
      // Gestione immagine (assumendo che sia un campo 'image' nel record)
      // image: record.getDataValue<String>('image').isNotEmpty
      //     ? pb.getFileUrl(record, record.getStringValue('image')).toString()
      //     : "https://via.placeholder.com/150",
    );
  }

  // Copia con modifiche per aggiornare lo stato
  EventModel copyWith({
    bool? iscritto,
  }) {
    return EventModel(
      title: title,
      description: description,
      date: date,
      place: place,
      difficulty: difficulty,
      requirements: requirements,
      id: id,
      iscritto: iscritto ?? this.iscritto,
      image: image,
      organizzatore: organizzatore,
      linkgruppo: linkgruppo,
      iscrizioniAperte: iscrizioniAperte,
    );
  }

  @override
  List<Object?> get props => [
        title,
        description,
        date,
        place,
        difficulty,
        requirements,
        id,
        iscritto,
        image,
        organizzatore,
        linkgruppo,
        iscrizioniAperte
      ];
      
        @override
        // TODO: implement cardId
        String get cardId => id;
      
        @override
        // TODO: implement cardImageUrl
        String get cardImageUrl => image;
      
        @override
        // TODO: implement cardSubtitle
        String get cardSubtitle => '${date.day}/${date.month}' ;
      
        @override
        // TODO: implement cardTitle
        String get cardTitle => title;
      
        @override
        // TODO: implement secondSubtitle
        String get secondSubtitle => 'Difficoltà: $difficulty';
}
