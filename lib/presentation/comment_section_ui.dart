import 'package:campo_base/bloc/comments/comments_bloc.dart';
import 'package:campo_base/bloc/comments/comments_event.dart';
import 'package:campo_base/bloc/comments/comments_state.dart';
import 'package:campo_base/data/repository/authRepository.dart';
import 'package:campo_base/data/model/comment_model.dart';
import 'package:campo_base/presentation/comment_item.dart'; // Importa il file esterno
import 'package:campo_base/temi.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CommentsSectionUI extends StatefulWidget {
  const CommentsSectionUI({Key? key}) : super(key: key);

  @override
  State<CommentsSectionUI> createState() => _CommentsSectionUIState();
}

class _CommentsSectionUIState extends State<CommentsSectionUI> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      // Invia solo il testo. Il BLoC recupera l'userId dall'AuthRepository
      context.read<CommentsBloc>().add(AddComment(text: text));
      _controller.clear();

      // Opzionale: chiude la tastiera
      FocusScope.of(context).unfocus();

      // Opzionale: scrolla in cima (o in fondo, a seconda del sort order)
      // _scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, String commentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Elimina commento", style: TextStyle(color: Colors.black)),
        content: const Text("Sei sicuro di voler eliminare questo commento?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annulla"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CommentsBloc>().add(DeleteComment(commentId));
            },
            child: const Text("Elimina", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showReportConfirmDialog(BuildContext context, Comment comment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Segnala commento", style: TextStyle(color: Colors.black)),
        content: const Text("Vuoi segnalare questo contenuto?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annulla"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CommentsBloc>().add(ReportComment(
                commentId: comment.id, 
                flaggedUserId: comment.authorId
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Contenuto segnalato.")),
              );
            },
            child: const Text("Segnala", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, Comment comment, bool isMe) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 1.05,
                child: Material(
                  color: Colors.transparent,
                  child: IgnorePointer(
                    child: CommentItem(
                      comment: comment,
                      isMe: isMe,
                      onDelete: () {}, 
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (isMe) {
                      _showDeleteConfirmDialog(context, comment.id);
                    } else {
                      _showReportConfirmDialog(context, comment);
                    }
                  },
                  icon: Icon(isMe ? Icons.delete_outline : Icons.flag_outlined),
                  label: Text(
                    isMe ? "Elimina commento" : "Segnala commento",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Recuperiamo l'ID corrente dalla "Source of Truth" (AuthRepository)
    final currentUserId = context.read<AuthRepository>().currentUserId;

    return Column(
      children: [
        // --- LISTA COMMENTI ---
        Expanded(
          child: BlocConsumer<CommentsBloc, CommentsState>(
            listener: (context, state) {
              if (state is CommentsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is CommentsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CommentsLoaded) {
                if (state.comments.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 5),
                  itemCount: state.comments.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final comment = state.comments[index];

                    // Logica per determinare se il commento è mio
                    final isMe = currentUserId != null && comment.authorId == currentUserId;

                    return GestureDetector(
                      onLongPress: () => _showOptionsDialog(context, comment, isMe),
                      child: CommentItem(
                        comment: comment,
                        isMe: isMe,
                        onDelete: () {
                          // Mostra dialog di conferma prima di eliminare
                          _showDeleteConfirmDialog(context, comment.id);
                        },
                      ),
                    );
                  },
                );
              }
              return const SizedBox(); // Stato iniziale
            },
          ),
        ),

        // --- INPUT AREA ---
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -2),
                blurRadius: 5,
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Scrivi un commento...",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                radius: 24,
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 50, color: Colors.grey.shade300),
          //const SizedBox(height: 16),
          Text(
            "Sii il primo a dire la tua!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// LA CLASSE INLINE CommentItem È STATA RIMOSSA PER USARE QUELLA DI comment_item.dart