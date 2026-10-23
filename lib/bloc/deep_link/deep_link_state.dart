part of 'deep_link_bloc.dart';

abstract class DeepLinkState extends Equatable {
  const DeepLinkState();
  @override
  List<Object?> get props => [];
}

class DeepLinkInitial extends DeepLinkState {}

// Stato che ordina di fare PUSH di una schermata specifica
class DeepLinkPushEventDetail extends DeepLinkState {
  final String eventId;

  const DeepLinkPushEventDetail(this.eventId);

  @override
  List<Object?> get props => [eventId];
}
