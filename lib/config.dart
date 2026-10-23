/// Indirizzi del backend PocketBase e del sito web, sovrascrivibili a build time:
/// flutter run --dart-define=API_URL=https://api.campobase.example
///
/// Finché il server di Campo Base non è deployato, il default punta al PocketBase
/// esistente (che contiene già le collezioni `events` e `iscrizioni`).
const String kApiBaseUrl = String.fromEnvironment('API_URL', defaultValue: 'https://projectodyssey.it');

/// Base dei link condivisi (`<base>/evento/<id>`).
const String kWebBaseUrl = String.fromEnvironment('WEB_URL', defaultValue: 'https://projectodyssey.it');
