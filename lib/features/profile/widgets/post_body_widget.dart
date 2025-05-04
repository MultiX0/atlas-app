import 'package:atlas_app/core/common/widgets/image_view_controller.dart';
import 'package:atlas_app/features/profile/widgets/interactions_bar.dart';
import 'package:atlas_app/features/profile/widgets/post_content_widget.dart';
import 'package:atlas_app/features/profile/widgets/post_mention_embed.dart';
import 'package:atlas_app/imports.dart';

class PostBodyWidget extends StatelessWidget {
  const PostBodyWidget({
    super.key,
    required this.post,
    required this.onComment,
    required this.onLike,
    required this.onRepost,
    required this.onShare,
    required this.hasArabic,
    this.hashtag,
  });

  final PostModel post;
  final bool hasArabic;
  final Future<bool?> Function(bool)? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;
  final String? hashtag;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: hasArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (post.updatedAt != null) ...[const SizedBox(height: 5), const Text("تم التعديل عليه")],
          const SizedBox(height: 10),
          PostContentWidget(post: post, hashtag: hashtag),
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            ViewImagesController(
              images: post.images.map((image) => CachedNetworkImageProvider(image)).toList(),
            ),
          ],
          const SizedBox(height: 15),

          if (post.images.isEmpty &&
              (post.charactersMentioned.isNotEmpty ||
                  post.manhwaMentioned.isNotEmpty ||
                  post.novelsMentioned.isNotEmpty)) ...[
            PostMentionEmbedWidget(post: post, key: ValueKey(post.postId)),
          ],
          const SizedBox(height: 12),
          InteractionBar(
            canRepost: post.canReposted,
            commentOpens: post.comments_open,
            isShared: post.shared_by_me,
            likes: post.likeCount,
            comments: post.commentsCount,
            reposts: post.repostedCount,
            shares: post.shares_count,
            isLiked: post.userLiked,
            onLike: onLike,
            onComment: onComment,
            onRepost: onRepost,
            onShare: onShare,
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
