/// Indirizzi del backend PocketBase e del sito web, sovrascrivibili a build time:
/// flutter run --dart-define=API_URL=https://api.campobase.example
///
/// Campo Base ha un PocketBase e account separati da Odyssey. Il default è il PocketBase
/// locale di sviluppo (`pocketbase serve`, porta 8090).
const String kApiBaseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8090');

/// Base dei link condivisi (`<base>/evento/<id>`).
const String kWebBaseUrl = String.fromEnvironment('WEB_URL', defaultValue: 'http://localhost:8090');
