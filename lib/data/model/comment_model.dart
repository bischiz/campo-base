import 'package:campo_base/config.dart';
import 'package:pocketbase/pocketbase.dart';

class Comment {
  final String id;
  final String text;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final DateTime created;

  Comment({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.created,
  });

  factory Comment.fromRecord(RecordModel record) {
    // Recuperiamo i dati dell'utente espanso (expand)
    final expand = record.expand;
    final authorRecord =
        (expand['utente'] as List?)?.isNotEmpty == true ? (expand['utente'] as List).first as RecordModel : null;

    return Comment(
      id: record.id,
      text: record.data['commento'] ?? '', // Campo 'commento'
      authorId: record.data['utente'] ?? '', // Campo 'utenti' (relation)
      authorName: authorRecord?.data['name'] ?? authorRecord?.data['username'] ?? 'Utente',
      // Costruisci l'URL dell'avatar se serve, o prendi il filename
      authorAvatar:
          "$kApiBaseUrl/api/files/_pb_users_auth_/${record.data["utente"]}/${authorRecord?.data['fotoProfilo']}",
      created: DateTime.parse(record.created),
    );
  }
}
