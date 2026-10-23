import 'package:campo_base/bloc/auth/auth_bloc.dart';
import 'package:campo_base/data/model/eventModel.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:campo_base/data/repository/eventiRepository.dart';

part 'eventi_event.dart';
part 'eventi_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final EventiRepository _eventsRepository;
  final AuthBloc _authBloc;

  EventsBloc({
    required EventiRepository eventsRepository,
    required AuthBloc authBloc,
  })  : _eventsRepository = eventsRepository,
        _authBloc = authBloc,
        super(const EventsState()) {
    on<LoadAllEvents>(_onLoadAllEvents);
    on<ChangeEventsPage>(_onChangeEventsPage);
    on<SubscribeToEvent>(_onSubscribeToEvent);
    on<UnsubscribeFromEvent>(_onUnsubscribeFromEvent);
    on<FetchEventForNavigation>(_onFetchEventForNavigation);
    on<ResetEventNavigation>((event, emit) {
      // Pulisce l'evento per evitare navigazioni multiple
      emit(state.copyWith(eventToNavigate: null));
    });
  }

  Future<void> _onFetchEventForNavigation(FetchEventForNavigation event, Emitter<EventsState> emit) async {
    // Opzionale: puoi mettere uno stato di loading globale se vuoi mostrare uno spinner
    // emit(state.copyWith(status: EventsStatus.loading));

    try {
      final userId = _getUserId();
      final eventModel = await _eventsRepository.getEventById(event.eventId, userId);

      // Emettiamo lo stato con l'evento popolato. La UI lo ascolterà.
      emit(state.copyWith(eventToNavigate: eventModel));
    } catch (e) {
      emit(state.copyWith(status: EventsStatus.failure, error: "Impossibile aprire l'evento: $e"));
    }
  }

  String _getUserId() {
    final authState = _authBloc.state;
    if (authState is Authenticated) {
      return (authState).user.id; // Adatta questo
    }
    throw Exception('Utente non autenticato');
  }

  Future<void> _onLoadAllEvents(LoadAllEvents event, Emitter<EventsState> emit) async {
    emit(state.copyWith(status: EventsStatus.loading));
    try {
      final data = await _eventsRepository.fetchAllEventsData(_getUserId());
      emit(state.copyWith(
        status: EventsStatus.success,
        pastEvents: data.pastEvents,
        officialEvents: data.officialEvents,
        eventDates: data.eventDates,
      ));
    } catch (e) {
      emit(state.copyWith(status: EventsStatus.failure, error: e.toString()));
    }
  }

  void _onChangeEventsPage(ChangeEventsPage event, Emitter<EventsState> emit) {
    emit(state.copyWith(selectedPageIndex: event.pageIndex));
  }

  // Logica di iscrizione (aggiorna lo stato localmente dopo la chiamata API)
  Future<void> _onSubscribeToEvent(SubscribeToEvent event, Emitter<EventsState> emit) async {
    try {
      await _eventsRepository.subscribeToEvent(event.eventId, _getUserId());
      // Aggiorna lo stato per riflettere il cambiamento
      final updateList = (List<EventModel> list) => list.map((e) {
            return e.id == event.eventId ? e.copyWith(iscritto: true) : e;
          }).toList();

      emit(state.copyWith(
        pastEvents: updateList(state.pastEvents),
        officialEvents: updateList(state.officialEvents),
      ));
    } catch (e) {/* Gestisci l'errore se vuoi */}
  }

  // Logica di disiscrizione
  Future<void> _onUnsubscribeFromEvent(UnsubscribeFromEvent event, Emitter<EventsState> emit) async {
    try {
      await _eventsRepository.unsubscribeFromEvent(event.eventId, _getUserId());
      final updateList = (List<EventModel> list) => list.map((e) {
            return e.id == event.eventId ? e.copyWith(iscritto: false) : e;
          }).toList();

      emit(state.copyWith(
        pastEvents: updateList(state.pastEvents),
        officialEvents: updateList(state.officialEvents),
      ));
    } catch (e) {/* Gestisci l'errore */}
  }
}
