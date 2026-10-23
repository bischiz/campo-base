part of 'eventi_bloc.dart';

enum EventsStatus { initial, loading, success, failure }

class EventsState extends Equatable {
  final EventsStatus status;
  final int selectedPageIndex;
  final List<EventModel> pastEvents;
  final List<EventModel> officialEvents;
  final Set<DateTime> eventDates;
  final String? error;

  // NUOVO CAMPO: L'evento pronto per la navigazione
  final EventModel? eventToNavigate;

  const EventsState({
    this.status = EventsStatus.initial,
    this.selectedPageIndex = 1,
    this.pastEvents = const <EventModel>[],
    this.officialEvents = const <EventModel>[],
    this.eventDates = const {},
    this.error,
    this.eventToNavigate, // Aggiunto al costruttore
  });

  EventsState copyWith({
    EventsStatus? status,
    int? selectedPageIndex,
    List<EventModel>? pastEvents,
    List<EventModel>? officialEvents,
    Set<DateTime>? eventDates,
    String? error,
    EventModel? eventToNavigate, // Aggiunto al copyWith
  }) {
    return EventsState(
      status: status ?? this.status,
      selectedPageIndex: selectedPageIndex ?? this.selectedPageIndex,
      pastEvents: pastEvents ?? this.pastEvents,
      officialEvents: officialEvents ?? this.officialEvents,
      eventDates: eventDates ?? this.eventDates,
      error: error ?? this.error,
      // Se passi null esplicitamente, resta null, altrimenti mantiene il valore precedente o lo sovrascrive
      eventToNavigate: eventToNavigate,
    );
  }

  @override
  List<Object?> get props =>
      [status, selectedPageIndex, pastEvents, officialEvents, eventDates, error, eventToNavigate];
}
