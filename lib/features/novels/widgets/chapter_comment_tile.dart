import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/cached_avatar.dart';
import 'package:atlas_app/core/common/widgets/reuseable_comment_widget.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/models/novel_chapter_comment_model.dart';
import 'package:atlas_app/imports.dart';

class ChapterCommentTile extends StatelessWidget {
  const ChapterCommentTile({super.key, required this.comment});

  final NovelChapterCommentWithMeta comment;
  static final Debouncer _debouncer = Debouncer();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CachedAvatar(avatar: comment.user.avatar, raduis: 20),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment.user.username),
                            const SizedBox(height: 2),
                            Consumer(
                              builder: (context, ref, _) {
                                return CommentRichTextView(text: comment.content, maxLines: 3);
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
                        onTap: (_) => handleLike(ref),
                        isLiked: comment.isLiked,
                        likeCount: comment.likesCount,
                      ),
                    );
                  },
                ),
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "رد",
                    style: TextStyle(
                      fontFamily: arabicAccentFont,
                      fontSize: 15,
                      color: AppColors.mutedSilver,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "ابلاغ",
                    style: TextStyle(
                      fontFamily: arabicAccentFont,
                      fontSize: 15,
                      color: AppColors.mutedSilver,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> handleLike(WidgetRef ref) async {
    _debouncer.debounce(
      duration: comment.isLiked ? Duration.zero : const Duration(milliseconds: 300),
      onDebounce: () {
        ref.read(novelsControllerProvider.notifier).handleChapterCommentLike(comment);
      },
    );
    return true;
  }
}
