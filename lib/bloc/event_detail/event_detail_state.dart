part of 'event_detail_bloc.dart';

enum EventDetailStatus { loading, success, failure }

class EventDetailState extends Equatable {
  final EventDetailStatus status;
  final List<ParticipantModel> participants;
  final String? error;

  const EventDetailState({
    this.status = EventDetailStatus.loading,
    this.participants = const [],
    this.error,
  });

  EventDetailState copyWith({
    EventDetailStatus? status,
    List<ParticipantModel>? participants,
    String? error,
  }) {
    return EventDetailState(
      status: status ?? this.status,
      participants: participants ?? this.participants,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, participants, error];
}
