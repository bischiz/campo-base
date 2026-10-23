import 'package:campo_base/data/model/partecipantModel.dart';
import 'package:campo_base/data/repository/eventiRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'event_detail_event.dart';
part 'event_detail_state.dart';

class EventDetailBloc extends Bloc<EventDetailEvent, EventDetailState> {
  final EventiRepository _eventsRepository;

  EventDetailBloc({required EventiRepository eventsRepository})
      : _eventsRepository = eventsRepository,
        super(const EventDetailState()) {
    on<LoadEventDetails>(_onLoadEventDetails);
  }

  Future<void> _onLoadEventDetails(
    LoadEventDetails event,
    Emitter<EventDetailState> emit,
  ) async {
    emit(state.copyWith(status: EventDetailStatus.loading));
    try {
      final participants = await _eventsRepository.getParticipants(event.eventId);

      emit(state.copyWith(
        status: EventDetailStatus.success,
        participants: participants,
      ));
    } catch (e) {
      emit(state.copyWith(status: EventDetailStatus.failure, error: e.toString()));
    }
  }
}
