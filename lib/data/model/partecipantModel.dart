import 'package:equatable/equatable.dart';
import 'package:pocketbase/pocketbase.dart';

class ParticipantModel extends Equatable {
  final String id;
  final String nomeUtente;
  final String imageUrl;

  const ParticipantModel({
    required this.id,
    required this.nomeUtente,
    required this.imageUrl,
  });
  factory ParticipantModel.fromUserRecord(dynamic userRecord, PocketBase pb) {
    // Sostituisci 'avatar' con il nome reale del campo avatar nel tuo DB 'users'
    final avatarFilename = userRecord.data['fotoProfilo'] as String? ?? '';

    String imageUrl = 'https://via.placeholder.com/150'; // Fallback

    if (avatarFilename.isNotEmpty) {
      // *** 2. USA 'pb' (il parametro), NON 'userRecord.pb' ***
      imageUrl = pb.getFileUrl(userRecord, avatarFilename).toString();
    }

    // Sostituisci 'username' con il nome reale del campo
    return ParticipantModel(
      id: userRecord.id,
      nomeUtente: userRecord.data['username'] ?? 'Utente',
      imageUrl: imageUrl,
    );
  }

  factory ParticipantModel.returnBlockedUser() {
    // Sostituisci 'avatar' con il nome reale del campo avatar nel tuo DB 'users'
    String imageUrl = 'https://via.placeholder.com/150'; // Fallback

    // Sostituisci 'username' con il nome reale del campo
    return ParticipantModel(
      id: 'blocked_user',
      nomeUtente: 'Utente Bloccato',
      imageUrl: imageUrl,
    );
  }
  
  @override
  List<Object> get props => [id, nomeUtente, imageUrl];
}
