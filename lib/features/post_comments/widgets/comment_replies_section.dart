import 'package:atlas_app/features/post_comments/models/comment_model.dart';
import 'package:atlas_app/features/post_comments/providers/comment_replies_providers.dart';
import 'package:atlas_app/features/post_comments/widgets/comment_tile.dart';
import 'package:atlas_app/imports.dart';

class PostCommentRepliesSection extends StatelessWidget {
  const PostCommentRepliesSection({super.key, required this.comment});

  final PostCommentModel comment;

  @override
  Widget build(BuildContext context) {
    final notifier = postCommentReplisStateNotifier(comment.id);
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
                return PostCommentTile(
                  reply: replies[i],
                  isReply: true,
                  parentCommentId: comment.id,
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
