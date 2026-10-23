// Segnaposto: genera il file vero con `flutterfire configure` sul progetto Firebase di Campo Base
// (non riutilizzare quello di Odyssey). Viene sovrascritto dal comando.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnimplementedError('Esegui `flutterfire configure` per generare firebase_options.dart');
  }
}
