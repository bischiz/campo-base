import 'package:campo_base/bloc/comments/comments_event.dart';
import 'package:campo_base/bloc/comments/comments_state.dart';
import 'package:campo_base/data/model/comment_enitity_type.dart';
import 'package:campo_base/data/repository/comments_repository.dart';
import 'package:campo_base/data/repository/authRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final CommentsRepository repository;
  final String entityId;
  final CommentEntityType entityType;
  final AuthRepository authRepository;

  CommentsBloc({
    required this.repository,
    required this.entityId,
    required this.entityType,
    required this.authRepository,
  }) : super(CommentsInitial()) {
    on<LoadComments>(_onLoadComments);
    on<AddComment>(_onAddComment);
    on<DeleteComment>(_onDeleteComment);
    // <<< REGISTRAZIONE HANDLER SEGNALAZIONE >>>
    on<ReportComment>(_onReportComment);
  }

  Future<void> _onLoadComments(LoadComments event, Emitter<CommentsState> emit) async {
    emit(CommentsLoading());
    try {
      final comments = await repository.getComments(
        entityId: entityId,
        type: entityType,
      );
      emit(CommentsLoaded(comments));
    } catch (e) {
      emit(CommentsError("Errore caricamento: $e"));
    }
  }

  Future<void> _onAddComment(AddComment event, Emitter<CommentsState> emit) async {
    final currentState = state;
    // RECUPERIAMO L'ID DALLA SINGLE SOURCE OF TRUTH
    final currentUserId = authRepository.currentUserId;

    if (currentUserId == null) {
      emit(CommentsError("Devi essere loggato per commentare"));
      return;
    }

    if (currentState is CommentsLoaded) {
      try {
        final newComment = await repository.addComment(
          text: event.text,
          userId: currentUserId, // Usiamo l'ID recuperato internamente
          entityId: entityId,
          type: entityType,
        );

        final updatedList = [newComment, ...currentState.comments];
        emit(CommentsLoaded(updatedList));
      } catch (e) {
        emit(CommentsError("Errore invio: $e"));
        add(LoadComments());
      }
    }
  }

  Future<void> _onDeleteComment(DeleteComment event, Emitter<CommentsState> emit) async {
    // Implementazione analoga a AddComment: chiami repo.delete e rimuovi dalla lista locale
  }

  /// <<< NUOVO HANDLER per segnalare un commento >>>
  Future<void> _onReportComment(ReportComment event, Emitter<CommentsState> emit) async {
    final currentState = state;
    final currentUserId = authRepository.currentUserId;
    
    if (currentUserId == null || currentState is! CommentsLoaded) return;

    // Logica di scomparsa immediata (ottimistica) per conformità Apple
    final updatedList = currentState.comments.where((c) => c.id != event.commentId).toList();
    emit(CommentsLoaded(updatedList));

    try {
      await repository.reportComment(
        fromUserId: currentUserId,
        flaggedUserId: event.flaggedUserId ?? '',       
        flaggedCommentId: event.commentId,
        feedback: event.feedback,
      );
    } catch (e) {
      // In caso di errore non facciamo nulla: il contenuto resta nascosto 
      // come da volontà dell'utente che ha segnalato.
    }
  }
}