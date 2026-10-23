import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Classe di supporto per trasportare i dati della notifica
class NotificationPayload {
  final String intentType; // es. 'evento', 'chat'
  final String? targetId; // es. 'record_id_123'

  NotificationPayload({required this.intentType, this.targetId});
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // MODIFICATO: Ora lo stream trasporta un oggetto Payload, non solo una stringa
  final _intentStreamController = StreamController<NotificationPayload>.broadcast();

  Stream<NotificationPayload> get notificationIntentStream => _intentStreamController.stream;

  Future<void> init() async {
    // 1. App aperta da notifica (stato terminato)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // 2. App aperta da notifica (stato background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    // Estraiamo i dati dal payload di Firebase
    final data = message.data;

    // Assumiamo che il backend mandi chiavi tipo "type" e "id" (o "eventId")
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    if (type != null) {
      // Emettiamo l'oggetto completo
      _intentStreamController.add(
        NotificationPayload(intentType: type, targetId: id),
      );
    }
  }

  Future<String?> getFcmToken() async {
    return await _fcm.getToken();
  }

  Future<void> requestPermissions() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
  }

  void dispose() {
    _intentStreamController.close();
  }
}
