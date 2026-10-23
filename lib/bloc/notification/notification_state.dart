part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationNavigationRequired extends NotificationState {
  final String navigationIntent; // 'chat', 'evento', 'amicizia'
  final String? targetId; // NUOVO: L'ID dell'oggetto (es. id evento)

  const NotificationNavigationRequired(this.navigationIntent, {this.targetId});

  @override
  List<Object?> get props => [navigationIntent, targetId];
}
