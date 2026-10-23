part of 'event_detail_bloc.dart';

abstract class EventDetailEvent extends Equatable {
  const EventDetailEvent();
  @override
  List<Object> get props => [];
}

/// Evento inviato dalla UI (EventDetailPage) per richiedere
/// il caricamento dei dati specifici (es. partecipanti).
class LoadEventDetails extends EventDetailEvent {
  final String eventId;
  const LoadEventDetails(this.eventId);

  @override
  List<Object> get props => [eventId];
}
