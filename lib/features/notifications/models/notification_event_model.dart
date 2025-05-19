// ignore_for_file: public_member_api_docs, sort_constructors_first
class NotificationEventRequest {
  final String recipientId;
  final String senderId;
  final String type;
  final String? postId;
  final String? postCommentId;
  final String? postReplyId;
  final String? novelId;
  final String? chapterId;
  final String? chapterCommentId;
  final String? chapterReplyId;
  final String? novelReviewId;
  final String? comicReviewId;
  final String? message;
  final dynamic metadata;
  final String token;

  NotificationEventRequest({
    required this.recipientId,
    required this.senderId,
    required this.type,
    this.postId,
    this.postCommentId,
    this.postReplyId,
    this.novelId,
    this.chapterId,
    this.chapterCommentId,
    this.chapterReplyId,
    this.novelReviewId,
    this.comicReviewId,
    this.message,
    this.metadata,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipient_id': recipientId,
      'sender_id': senderId,
      'type': type,
      if (postId != null) 'post_id': postId,
      if (postCommentId != null) 'post_comment_id': postCommentId,
      if (postReplyId != null) 'post_reply_id': postReplyId,
      if (novelId != null) 'novel_id': novelId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (chapterCommentId != null) 'chapter_comment_id': chapterCommentId,
      if (chapterReplyId != null) 'chapter_reply_id': chapterReplyId,
      if (novelReviewId != null) 'novel_review_id': novelReviewId,
      if (comicReviewId != null) 'comic_review_id': comicReviewId,
      if (message != null) 'message': message,
      if (metadata != null) 'metadata': metadata,
      'token': token,
    };
  }

  factory NotificationEventRequest.fromJson(Map<String, dynamic> json) {
    return NotificationEventRequest(
      recipientId: json['recipient_id'],
      senderId: json['sender_id'],
      type: json['type'],
      postId: json['post_id'],
      postCommentId: json['post_comment_id'],
      postReplyId: json['post_reply_id'],
      novelId: json['novel_id'],
      chapterId: json['chapter_id'],
      chapterCommentId: json['chapter_comment_id'],
      chapterReplyId: json['chapter_reply_id'],
      novelReviewId: json['novel_review_id'],
      comicReviewId: json['comic_review_id'],
      message: json['message'],
      metadata: json['metadata'],
      token: json['token'],
    );
  }

  NotificationEventRequest copyWith({
    String? recipientId,
    String? senderId,
    String? type,
    String? postId,
    String? postCommentId,
    String? postReplyId,
    String? novelId,
    String? chapterId,
    String? chapterCommentId,
    String? chapterReplyId,
    String? novelReviewId,
    String? comicReviewId,
    String? message,
    dynamic metadata,
    String? token,
  }) {
    return NotificationEventRequest(
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      postId: postId ?? this.postId,
      postCommentId: postCommentId ?? this.postCommentId,
      postReplyId: postReplyId ?? this.postReplyId,
      novelId: novelId ?? this.novelId,
      chapterId: chapterId ?? this.chapterId,
      chapterCommentId: chapterCommentId ?? this.chapterCommentId,
      chapterReplyId: chapterReplyId ?? this.chapterReplyId,
      novelReviewId: novelReviewId ?? this.novelReviewId,
      comicReviewId: comicReviewId ?? this.comicReviewId,
      message: message ?? this.message,
      metadata: metadata ?? this.metadata,
      token: token ?? this.token,
    );
  }
}
