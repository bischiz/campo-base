abstract class CommentsEvent {}

class LoadComments extends CommentsEvent {}

class AddComment extends CommentsEvent {
  final String text;
  AddComment({required this.text});
}

class DeleteComment extends CommentsEvent {
  final String commentId;
  DeleteComment(this.commentId);
}

class ReportComment extends CommentsEvent {
  final String commentId;
  final String? feedback;
  final String? flaggedUserId;

  ReportComment({required this.commentId, this.feedback, this.flaggedUserId});
}