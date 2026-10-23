import 'package:campo_base/data/model/comment_enitity_type.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../model/comment_model.dart';
import 'package:campo_base/data/repository/authRepository.dart'; // Import necessario

class CommentsRepository {
  final PocketBase pb;
  final AuthRepository _authRepository; // Nuova dipendenza

  CommentsRepository({required this.pb, required AuthRepository authRepository}) 
      : _authRepository = authRepository;

  // FETCH
  Future<List<Comment>> getComments({
    required String entityId,
    required CommentEntityType type,
  }) async {
    // 1. Selezioniamo la collection corretta
    final collection = type.collectionName;

    // 2. Creiamo il filtro: es. "evento = 'ID123'" oppure "posto = 'ID456'"
    final filter = '${type.relationField} = "$entityId"';

    final result = await pb.collection(collection).getList(
          sort: '-created',
          filter: filter,
          expand: 'utente', // Espandiamo la relazione utente
        );
    final blockedComments = await fetchBlockedComments();
    // Recupera la lista bloccati
    final blockedIds = _authRepository.blockedUserIds;

    // Filtra via i commenti degli utenti bloccati
    return result.items
        .map((r) => Comment.fromRecord(r))
        .where((c) => !blockedIds.contains(c.authorId) && !blockedComments.contains(c.id))
        .toList();
  }

  // ADD
  Future<Comment> addComment({
    required String text,
    required String userId,
    required String entityId,
    required CommentEntityType type,
  }) async {
    final collection = type.collectionName;

    final body = <String, dynamic>{
      'commento': text,
      'utente': userId,
      // Qui assegniamo l'ID all'entità corretta (es. 'evento': '123')
      type.relationField: entityId,
    };

    final record = await pb.collection(collection).create(body: body, expand: 'utente');
    return Comment.fromRecord(record);
  }

  // DELETE
  Future<void> deleteComment({
    required String commentId,
    required CommentEntityType type, // Ci serve il tipo per sapere da quale collection cancellare
  }) async {
    await pb.collection(type.collectionName).delete(commentId);
  }

  Future<void> reportComment({
    required String fromUserId,
    required String flaggedUserId,
    String? flaggedCommentId,
    String? feedback,
  }) async {
    try {
      await pb.collection('segnalazione').create(body: {
        'from_user': fromUserId,
        'flagged_user': flaggedUserId,
        'flagged_comment': flaggedCommentId ?? "", // Vuoto se segnaliamo l'utente
        'user_feedback': feedback ?? "",
        'solved': false,
      });
    } catch (e) {
      debugPrint("Errore durante la creazione della segnalazione: $e");
      throw Exception("Impossibile inviare la segnalazione");
    }
    if (flaggedCommentId == null || flaggedCommentId.isEmpty) {
      // Segnaliamo l'utente, quindi aggiorniamo la lista blocchi locale
    _authRepository.blockUserLocally(flaggedUserId);
    }
  } 

  Future<List<String>> fetchBlockedComments() async {
    try {
      final result = await pb.collection('segnalazione').getList(
        filter: 'from_user = "${_authRepository.currentUserId}" && flagged_comment != ""',
      );

      // Estrai gli ID degli utenti bloccati
      return result.items
          .map((record) => record.getStringValue('flagged_comment'))
          .toList();
    } catch (e) {
      debugPrint("Errore durante il recupero della lista blocchi: $e");
      return [];
    }
  }
}