part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => []; // Cambiato Object in Object? per sicurezza
}

class InitializeNotificationListeners extends NotificationEvent {}

class RegisterFcmToken extends NotificationEvent {}

class RequestNotificationPermissions extends NotificationEvent {}

class ClearNotificationIntent extends NotificationEvent {}

// MODIFICATO: Aggiunto targetId
class _NotificationIntentReceived extends NotificationEvent {
  final String intent;
  final String? targetId; // L'ID estratto dal payload della notifica

  const _NotificationIntentReceived(this.intent, {this.targetId});

  @override
  List<Object?> get props => [intent, targetId];
}
