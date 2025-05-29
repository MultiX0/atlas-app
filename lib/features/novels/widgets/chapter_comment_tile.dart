import 'dart:developer';

import 'package:atlas_app/core/common/enum/comment_type.dart';
import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/cached_avatar.dart';
import 'package:atlas_app/core/common/widgets/reuseable_comment_widget.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/models/novel_chapter_comment_model.dart';
import 'package:atlas_app/features/novels/models/novel_chapter_comment_reply_model.dart';
import 'package:atlas_app/features/novels/providers/chapter_comments_replies.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/features/novels/widgets/comment_report_sheet.dart';
import 'package:atlas_app/imports.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChapterCommentTile extends StatelessWidget {
  const ChapterCommentTile({
    super.key,
    this.comment,
    this.reply,
    this.isReply = false,
    required this.chapterId,
    this.parentCommentId,
  }) : assert(
         (comment != null && reply == null) || (comment == null && reply != null),
         'Either comment or reply must be provided, but not both',
       );

  final NovelChapterCommentWithMeta? comment;
  final NovelChapterCommentReplyWithLikes? reply;
  final bool isReply;
  final String? parentCommentId;
  final String chapterId;
  static final Debouncer _debouncer = Debouncer();

  @override
  Widget build(BuildContext context) {
    // Get common properties based on whether this is a comment or reply
    final String content = isReply ? reply!.content : comment!.content;
    final DateTime createdAt = isReply ? reply!.createdAt : comment!.createdAt;
    final DateTime? updatedAt = isReply ? reply!.updatedAt : comment!.updatedAt;
    final bool isEdited = isReply ? reply!.isEdited : comment!.isEdited;
    final bool isLiked = isReply ? reply!.isLiked : comment!.isLiked;
    final int likesCount = isReply ? reply!.likesCount : comment!.likesCount;
    final UserModel user = isReply ? reply!.user : comment!.user;
    final String id = isReply ? reply!.id : comment!.id;
    final String parentUserId = isReply ? reply!.userId : comment!.userId;
    final String commentId = isReply ? reply!.commentId : comment!.id;
    final UserModel parentUser = isReply ? reply!.user : comment!.user;

    return RepaintBoundary(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(isReply ? 10 : 20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isReply)
                Divider(height: 0.25, color: AppColors.mutedSilver.withValues(alpha: .08)),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CachedAvatar(
                          avatar: user.avatar,
                          raduis: 20,
                          onTap: () => context.push("${Routes.user}/${user.userId}"),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(user.username),
                                  if (user.isAdmin || user.official) ...[const SizedBox(width: 5)],
                                  Visibility(
                                    visible: (user.isAdmin || user.official),
                                    child: const Icon(
                                      LucideIcons.badge_check,
                                      color: AppColors.primary,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(' · '),
                                  Text(
                                    (timeago.format(createdAt, locale: 'ar')),
                                    style: const TextStyle(color: AppColors.mutedSilver),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              if (isEdited || updatedAt != null) ...[
                                const Text(
                                  ('تم التعديل'),
                                  style: TextStyle(color: AppColors.mutedSilver),
                                ),
                                const SizedBox(height: 5),
                              ],
                              if (isReply) ...[
                                Text(
                                  "رد على ${reply!.parent_user.username}",
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontFamily: arabicAccentFont,
                                  ),
                                ),
                                const SizedBox(height: 5),
                              ],
                              Consumer(
                                builder: (context, ref, _) {
                                  return CommentRichTextView(text: content, maxLines: 3);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Consumer(
                    builder: (context, ref, _) {
                      return Directionality(
                        textDirection: TextDirection.ltr,
                        child: CustomLikeButton(
                          onTap: (_) => handleLike(ref, id, isReply),
                          isLiked: isLiked,
                          likeCount: likesCount,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Consumer(
                builder: (context, ref, _) {
                  final me = ref.read(userState.select((s) => s.user));
                  if (me == null) return const Text("error with user data");
                  final novel = ref.read(selectedNovelProvider);
                  if (novel == null) return const Text("error with novel data");

                  final isMeOrCreator = (me.userId == novel.userId) || (user.userId == me.userId);
                  final isMe = user.userId == me.userId;
                  return Row(
                    children: [
                      TextButton(
                        onPressed:
                            () => handleAction(
                              ref,
                              commentId,
                              parentUserId,
                              content,
                              user.username,
                              parentUser,
                              true,
                              context,
                            ),
                        child: const Text(
                          "رد",
                          style: TextStyle(
                            fontFamily: arabicAccentFont,
                            fontSize: 15,
                            color: AppColors.mutedSilver,
                          ),
                        ),
                      ),
                      if (!isMe)
                        TextButton(
                          onPressed:
                              () => handleAction(
                                ref,
                                id,
                                parentUserId,
                                content,
                                user.username,
                                parentUser,
                                isReply,
                                context,
                              ),
                          child: const Text(
                            "ابلاغ",
                            style: TextStyle(
                              fontFamily: arabicAccentFont,
                              fontSize: 15,
                              color: AppColors.mutedSilver,
                            ),
                          ),
                        ),
                      if (isMeOrCreator) ...[
                        TextButton(
                          onPressed: () => handleDelete(context, ref, isReply, commentId, id),
                          child: const Text(
                            "حذف",
                            style: TextStyle(
                              fontFamily: arabicAccentFont,
                              fontSize: 15,
                              color: AppColors.mutedSilver,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              if (!isReply && comment != null && comment!.repliesCount > 0) ...[
                CommentRepliesSection(comment: comment!),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void handleAction(
    WidgetRef ref,
    String id,
    String parentUserId,
    String content,
    String username,
    UserModel parentUser,
    bool isReply,
    BuildContext context,
  ) async {
    try {
      final _map = {
        KeyNames.parent_comment_author_id: parentUserId,
        KeyNames.comment_id: id,
        KeyNames.content: content,
        KeyNames.username: username,
        KeyNames.parent_user: parentUser,
        'is_reply': isReply,
      };

      ref.read(repliedToProvider.notifier).state = _map;
      if (!isReply) {
        openSheet(
          context: context,
          child: const CommentReportSheet(commentType: CommentType.novel),
        );
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  void handleDelete(
    BuildContext context,
    WidgetRef ref,
    isReply,
    String commentId,
    String id,
  ) async {
    const btnStyle = TextStyle(fontFamily: arabicAccentFont, color: AppColors.primary);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryAccent,
          title: const Text(
            textDirection: TextDirection.rtl,
            "تأكيد الحذف",
            style: TextStyle(fontFamily: arabicAccentFont),
          ),
          content: const Text(
            "هل أنت متأكد أنك تريد حذف هذا التعليق؟",
            style: TextStyle(fontFamily: arabicPrimaryFont),
            textDirection: TextDirection.rtl,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                context.pop();
                ref
                    .read(novelsControllerProvider.notifier)
                    .handleCommentDelete(
                      isReply: isReply,
                      id: id,
                      commentId: commentId,
                      chapterId: chapterId,
                    );
              },
              child: const Text("الااستمرار", style: btnStyle),
            ),
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("عودة", style: btnStyle),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> handleLike(WidgetRef ref, String id, bool isReply) async {
    _debouncer.debounce(
      duration:
          (isReply ? reply!.isLiked : comment!.isLiked)
              ? Duration.zero
              : const Duration(milliseconds: 300),
      onDebounce: () {
        if (isReply) {
          // Call the appropriate method for handling reply likes
          ref
              .read(novelsControllerProvider.notifier)
              .handleChapterCommentReplyLike(reply!, chapterId: chapterId);
        } else {
          ref.read(novelsControllerProvider.notifier).handleChapterCommentLike(comment!);
        }
      },
    );
    return true;
  }
}

class CommentRepliesSection extends StatelessWidget {
  const CommentRepliesSection({super.key, required this.comment});

  final NovelChapterCommentWithMeta comment;

  @override
  Widget build(BuildContext context) {
    final notifier = novelChapterCommentRepliesState(comment.id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Consumer(
        builder: (context, ref, child) {
          final replies = ref.watch(notifier.select((s) => s.comments));
          final loadMore = ref.watch(notifier.select((s) => s.loadingMore));
          final loading = ref.watch(notifier.select((s) => s.isLoading));
          final hasMore = ref.watch(notifier.select((s) => !s.hasReachedEnd));
          if (loading && replies.isEmpty) {
            return const Text(
              "جاري التحميل...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                fontFamily: arabicAccentFont,
              ),
            );
          }

          if (replies.isEmpty) return child!;

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: replies.length + (loadMore || hasMore ? 1 : 0),
            addRepaintBoundaries: true,
            addSemanticIndexes: true,
            itemBuilder: (context, i) {
              // Display regular replies
              if (i < replies.length) {
                return ChapterCommentTile(
                  reply: replies[i],
                  isReply: true,
                  parentCommentId: comment.id,
                  chapterId: comment.chapterId,
                );
              }

              // Display loading indicator or "load more" button
              if (loadMore) {
                return const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Loader(),
                );
              } else if (hasMore) {
                return GestureDetector(
                  onTap: () => ref.read(notifier.notifier).fetchData(),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          "المزيد...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            fontFamily: arabicAccentFont,
                          ),
                        ),
                        SizedBox(width: 15),
                        Icon(LucideIcons.chevron_down, size: 14),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
        child: Consumer(
          builder: (context, ref, _) {
            return GestureDetector(
              onTap: () {
                ref.read(notifier.notifier).fetchData();
              },
              child: Row(
                children: [
                  Text(
                    comment.repliesCount == 1 ? 'رد واحد...' : "${comment.repliesCount} ردود",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      fontFamily: arabicAccentFont,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Icon(LucideIcons.chevron_left, size: 14),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
