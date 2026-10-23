part of 'eventi_bloc.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();
  @override
  List<Object> get props => [];
}

/// Inviato dalla UI per caricare tutti i dati.
class LoadAllEvents extends EventsEvent {}

class ChangeEventsPage extends EventsEvent {
  final int pageIndex;
  const ChangeEventsPage(this.pageIndex);
  @override
  List<Object> get props => [pageIndex];
}

// Eventi per l'iscrizione (li useremo dalla pagina di dettaglio)
class SubscribeToEvent extends EventsEvent {
  final String eventId;
  const SubscribeToEvent(this.eventId);
  @override
  List<Object> get props => [eventId];
}

class UnsubscribeFromEvent extends EventsEvent {
  final String eventId;
  const UnsubscribeFromEvent(this.eventId);
  @override
  List<Object> get props => [eventId];
}

class FetchEventForNavigation extends EventsEvent {
  final String eventId;
  const FetchEventForNavigation(this.eventId);

  @override
  List<Object> get props => [eventId];
}

/// Evento per resettare lo stato di navigazione dopo il push
class ResetEventNavigation extends EventsEvent {}
