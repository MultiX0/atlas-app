enum NotificationType {
  postComment,
  postCommentReply,
  postMention,
  commentMention,
  replyMention,
  postRepost,
  postLike,
  commentLike,
  replyLike,

  novelFavorite,
  novelChapterLike,
  newNovelReview,
  novelChapterComment,
  novelChapterCommentReply,
  novelChapterCommentLike,
  novelChapterReplyLike,
  novelCommentMention,
  novelReplyMention,
  novelReviewReply,
  novelReviewLike,

  follow,

  comicReviewReply,
  comicReviewLike;

  static const Map<String, NotificationType> _stringToEnum = {
    'post_comment': NotificationType.postComment,
    'post_comment_reply': NotificationType.postCommentReply,
    'post_mention': NotificationType.postMention,
    'comment_mention': NotificationType.commentMention,
    'reply_mention': NotificationType.replyMention,
    'post_repost': NotificationType.postRepost,
    'post_like': NotificationType.postLike,
    'comment_like': NotificationType.commentLike,
    'reply_like': NotificationType.replyLike,

    'novel_favorite': NotificationType.novelFavorite,
    'novel_chapter_like': NotificationType.novelChapterLike,
    'novel_chapter_comment': NotificationType.novelChapterComment,
    'novel_chapter_comment_reply': NotificationType.novelChapterCommentReply,
    'novel_chapter_comment_like': NotificationType.novelChapterCommentLike,
    'novel_chapter_reply_like': NotificationType.novelChapterReplyLike,
    'novel_comment_mention': NotificationType.novelCommentMention,
    'novel_reply_mention': NotificationType.novelReplyMention,
    'novel_review_reply': NotificationType.novelReviewReply,
    'novel_review_like': NotificationType.novelReviewLike,
    'new_novel_review': NotificationType.newNovelReview,

    'comic_review_reply': NotificationType.comicReviewReply,
    'comic_review_like': NotificationType.comicReviewLike,
    'follow': NotificationType.follow,
  };

  static NotificationType? fromString(String value) {
    return _stringToEnum[value];
  }
}

const Map<NotificationType, String> _enumToString = {
  NotificationType.postComment: 'post_comment',
  NotificationType.postCommentReply: 'post_comment_reply',
  NotificationType.postMention: 'post_mention',
  NotificationType.commentMention: 'comment_mention',
  NotificationType.replyMention: 'reply_mention',
  NotificationType.postRepost: 'post_repost',
  NotificationType.postLike: 'post_like',
  NotificationType.commentLike: 'comment_like',
  NotificationType.replyLike: 'reply_like',

  NotificationType.novelFavorite: 'novel_favorite',
  NotificationType.novelChapterLike: 'novel_chapter_like',
  NotificationType.novelChapterComment: 'novel_chapter_comment',
  NotificationType.novelChapterCommentReply: 'novel_chapter_comment_reply',
  NotificationType.novelChapterCommentLike: 'novel_chapter_comment_like',
  NotificationType.novelChapterReplyLike: 'novel_chapter_reply_like',
  NotificationType.novelCommentMention: 'novel_comment_mention',
  NotificationType.novelReplyMention: 'novel_reply_mention',
  NotificationType.novelReviewReply: 'novel_review_reply',
  NotificationType.novelReviewLike: 'novel_review_like',
  NotificationType.newNovelReview: 'new_novel_review',

  NotificationType.comicReviewReply: 'comic_review_reply',
  NotificationType.comicReviewLike: 'comic_review_like',
  NotificationType.follow: 'follow',
};

String notificationEnumToString(NotificationType type) {
  return _enumToString[type] ?? "";
}
