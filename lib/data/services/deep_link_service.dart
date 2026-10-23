import 'dart:async';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  final dynamic _appLinks = AppLinks();

  // Stream controller per esporre gli URI puliti al Bloc
  final _linkController = StreamController<Uri>.broadcast();
  Stream<Uri> get linkStream => _linkController.stream;

  Future<void> init() async {
    // 1. Gestione link all'avvio (App chiusa -> aperta da link)
    try {
      // *** MODIFICA QUI: Usa getInitialAppLink() ***
      final initialUri = await _appLinks.getInitialAppLink();

      if (initialUri != null) {
        _linkController.add(initialUri);
      }
    } catch (e) {
      // Gestione errori silenziosa o log
      print("Errore DeepLink Initial: $e");
    }

    // 2. Ascolto stream (App in background -> riaperta da link)
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _linkController.add(uri);
      }
    }, onError: (err) {
      print("Errore DeepLink Stream: $err");
    });
  }

  void dispose() {
    _linkController.close();
  }
}
