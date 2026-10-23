import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:campo_base/data/services/secure_storage_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Assicurati di avere intl nel pubspec

class AuthRepository {
  final PocketBase _pb;
  final SecureStorageService _persistenceService;

  // 1. CACHE UTENTI BLOCCATI
  List<String> _blockedUserIds = [];
  List<String> get blockedUserIds => _blockedUserIds;

  AuthRepository({required PocketBase pb, required SecureStorageService persistenceService})
      : _pb = pb,
        _persistenceService = persistenceService;

  bool get isSignedIn => _pb.authStore.isValid;
  RecordModel? get user => _pb.authStore.model;

  void blockUserLocally(String userId) {
    if (!_blockedUserIds.contains(userId)) {
      _blockedUserIds.add(userId);
    }
  }
  
  Future<void> _updateBlockedUsers() async {
  if (_pb.authStore.isValid && _pb.authStore.record != null) {
    
    final currentUserId = _pb.authStore.record!.id; 

    try {
      final result = await _pb.collection('segnalazione').getFullList(
        // flagged_adventure = null: segnalazione sull'utente, non su un post
        filter: 'from_user = "$currentUserId" && flagged_adventure = null && flagged_comment = null',
        fields: 'flagged_user', 
      );

      _blockedUserIds = result
          .map((item) => item.getStringValue('flagged_user'))
          .where((id) => id.isNotEmpty)
          .toList();
          
    } catch (e) {
      print('Errore recupero blocchi: $e');
      _blockedUserIds = [];
    }
  } else {
    _blockedUserIds = [];
  }
}

  Future<void> init() async {
    final token = await _persistenceService.readAuthToken();

    if (token != null && token.isNotEmpty) {
      _pb.authStore.save(token, null);
      try {
        await _pb.collection('users').authRefresh();
        _updateBlockedUsers(); // Aggiorna lista dopo refresh
        debugPrint('✅ Sessione valida, token rinfrescato.');
      } catch (_) {
        debugPrint('❌ Sessione non valida, pulizia del token.');
        _pb.authStore.clear();
        await _persistenceService.deleteAuthToken();
      }
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      var response = await _pb.collection('users').authWithPassword(email, password);
      _updateBlockedUsers(); // Aggiorna lista dopo login
      await _persistenceService.saveAuthToken(_pb.authStore.token);
    } catch (e) {
      print(e.toString());
      _pb.authStore.clear();
      throw Exception('Login fallito. Controlla le tue credenziali.');
    }
  }

  Future<void> logout() async {
    _pb.authStore.clear();
    _blockedUserIds = []; // Pulisci lista al logout
    await _persistenceService.deleteAuthToken();
  }

  // Aggiornato con birthDate
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    required DateTime birthDate,
  }) async {
    try {
      final body = <String, dynamic>{
        "email": email,
        "password": password,
        "passwordConfirm": password,
        "username": username,
        // Formato richiesto da PocketBase per le date (o stringa standard)
        "data_di_nascita": DateFormat('yyyy-MM-dd').format(birthDate),
        "migrazione": true,
        // I campi sesso, avatar e provincia sono stati omessi come richiesto
      };

      await _pb.collection('users').create(body: body);

      // Richiedi verifica email come nel vecchio codice
      await _pb.collection('users').requestVerification(email);
    } on ClientException catch (e) {
      if (e.statusCode == 400) {
        // Cerca di estrarre un messaggio più specifico se possibile
        throw Exception('Dati non validi (Username o Email già in uso).');
      }
      throw Exception('Errore durante la registrazione: ${e.response}');
    } catch (e) {
      throw Exception('Si è verificato un errore sconosciuto.');
    }
  }

  // Nuovo metodo per il reset password
  Future<void> requestPasswordReset(String email) async {
    try {
      await _pb.collection('users').requestPasswordReset(email);
    } catch (e) {
      throw Exception('Impossibile inviare la mail di recupero.');
    }
  }

  Future<void> authWithGoogle() async {
    try {
      // 'google' è il nome del provider configurato in PocketBase
      // urlCallback è la funzione che apre il browser
      await _pb.collection('users').authWithOAuth2('google', (url) async {
        // Lancia il browser esterno (o una Custom Tab) per il login
        await launchUrl(
          url,
          mode: LaunchMode.inAppBrowserView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      });

      // Se il login ha successo, salva il token
      if (_pb.authStore.isValid) {
        _updateBlockedUsers(); // Aggiorna lista dopo Google Login
        await _persistenceService.saveAuthToken(_pb.authStore.token);
      } else {
        throw Exception("Login Google fallito o annullato.");
      }
    } catch (e) {
      // Pulisci in caso di errore
      _pb.authStore.clear();
      throw Exception('Errore login Google: $e');
    }
  }

  String? get currentUserId => _pb.authStore.model?.id;
}