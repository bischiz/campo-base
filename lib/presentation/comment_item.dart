import 'package:campo_base/data/model/comment_model.dart';
import 'package:campo_base/presentation/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;
  final bool isMe;
  final VoidCallback onDelete;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.isMe,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formattazione data
    final dateString = DateFormat('dd MMM, HH:mm').format(comment.created);

    return ProfileCard(
      layout: ProfileCardLayout.flat, // Layout piatto per i commenti
      title: comment.authorName,
      imageUrl: comment.authorAvatar,
      isHighlighted: isMe,
      
      // La data va in alto a destra
      trailing: Text(
        dateString,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
      
      // Il testo del commento viene passato come contenuto
      content: Text(
        comment.text,
        style: const TextStyle(fontSize: 15, height: 1.3, color: Colors.black87),
      ),
      
    );
  }
}