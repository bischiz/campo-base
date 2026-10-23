import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Crea un'istanza del plugin
  final _storage = const FlutterSecureStorage();

  // Chiave univoca per salvare il nostro token
  static const _authTokenKey = 'pb_auth';

  /// Salva il token di autenticazione in modo sicuro.
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  /// Legge il token di autenticazione dallo storage sicuro.
  /// Ritorna null se il token non è presente.
  Future<String?> readAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  /// Cancella il token di autenticazione dallo storage.
  Future<void> deleteAuthToken() async {
    await _storage.delete(key: _authTokenKey);
  }
}
