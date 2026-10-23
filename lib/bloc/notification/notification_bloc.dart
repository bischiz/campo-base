import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:campo_base/bloc/auth/auth_bloc.dart';
import 'package:campo_base/data/repository/token_repository.dart'; // Contiene la classe UserRepository
import '../../data/services/notification_service.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _notificationService;
  final UserRepository _userRepository; // Classe definita in token_repository.dart
  final AuthBloc _authBloc;

  StreamSubscription? _authSubscription;
  StreamSubscription? _intentSubscription;

  NotificationBloc({
    required NotificationService notificationService,
    required UserRepository userRepository,
    required AuthBloc authBloc,
  })  : _notificationService = notificationService,
        _userRepository = userRepository,
        _authBloc = authBloc,
        super(NotificationInitial()) {
    // 1. ASCOLTO DELL'AUTH (Corretto in base ai tuoi file)
    // Usiamo 'is Authenticated' come definito in auth_state.dart
    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState is Authenticated) {
        // Se l'utente è autenticato, registriamo il token
        add(RegisterFcmToken());
      }
    });

    // 2. INIZIALIZZAZIONE (App start)
    on<InitializeNotificationListeners>((event, emit) async {
      await _notificationService.init();

      await _intentSubscription?.cancel();
      _intentSubscription = _notificationService.notificationIntentStream.listen((payload) {
        add(_NotificationIntentReceived(payload.intentType, targetId: payload.targetId));
      });
    });

    // 3. RICHIESTA PERMESSI
    // Chiama il service reale e poi tenta la registrazione token
    on<RequestNotificationPermissions>((event, emit) async {
      await _notificationService.requestPermissions();
      add(RegisterFcmToken());
    });

    // 4. REGISTRAZIONE TOKEN
    // Chiama il metodo updateFcmToken del repository reale
    on<RegisterFcmToken>((event, emit) async {
      // Procediamo solo se l'utente è effettivamente loggato al momento dell'esecuzione
      if (_authBloc.state is Authenticated) {
        try {
          final token = await _notificationService.getFcmToken();
          if (token != null) {
            debugPrint('📲 FCM Token inviato al DB: $token');
            await _userRepository.updateFcmToken(token);
          }
        } catch (e) {
          debugPrint('❌ Errore updateFcmToken: $e');
        }
      }
    });

    // 5. GESTIONE NAVIGAZIONE
    on<_NotificationIntentReceived>((event, emit) {
      emit(NotificationNavigationRequired(event.intent, targetId: event.targetId));
    });

    // 6. RESET
    on<ClearNotificationIntent>((event, emit) {
      emit(NotificationInitial());
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _intentSubscription?.cancel();
    _notificationService.dispose();
    return super.close();
  }
}
