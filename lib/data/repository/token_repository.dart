import 'package:flutter/widgets.dart';
import 'package:pocketbase/pocketbase.dart';

class UserRepository {
  final PocketBase _pb;

  UserRepository({required PocketBase pb}) : _pb = pb;

  /// Aggiorna il token FCM per l'utente attualmente loggato.
  Future<void> updateFcmToken(String token) async {
    if (!_pb.authStore.isValid) return; // Non fare nulla se non loggato

    try {
      final userId = _pb.authStore.model!.id;
      await _pb.collection('users').update(userId, body: {'fcmToken': token});
      debugPrint('✅ Token FCM aggiornato con successo.');
    } catch (e) {
      debugPrint('❌ Errore aggiornamento token FCM: $e');
      // Gestisci l'errore (es. log, ecc.)
    }
  }
}
