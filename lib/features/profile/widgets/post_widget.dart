import 'package:atlas_app/features/posts/models/post_model.dart';
import 'package:atlas_app/features/profile/widgets/post_body_widget.dart';
import 'package:atlas_app/features/profile/widgets/post_header.dart';
import 'package:atlas_app/features/profile/widgets/post_replayed_widget.dart';
import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';

class PostWidget extends ConsumerWidget {
  PostWidget({
    super.key,
    required this.post,
    required this.onComment,
    required this.onLike,
    required this.onRepost,
    required this.onShare,
    this.hashtag,
  }) : hasArabic = Bidi.hasAnyRtl(post.content);

  final PostModel post;
  final bool hasArabic;
  final Future<bool?> Function(bool)? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;
  final String? hashtag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        child: Column(
          crossAxisAlignment: hasArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,

          children: [
            Divider(height: 0.25, color: AppColors.mutedSilver.withValues(alpha: .1)),
            const SizedBox(height: 15),
            if (post.parent != null) ...[PostReplyedWidget(post: post), const SizedBox(height: 8)],

            PostHeaderWidget(post: post),
            PostBodyWidget(
              post: post,
              hashtag: hashtag,
              hasArabic: hasArabic,
              onComment: onComment,
              onLike: onLike,
              onRepost: onRepost,
              onShare: onShare,
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
