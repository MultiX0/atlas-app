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
  }) : hasArabic = Bidi.hasAnyRtl(post.content);

  final PostModel post;
  final bool hasArabic;
  final Future<bool?> Function(bool)? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Column(
          crossAxisAlignment: hasArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,

          children: [
            if (post.parent != null) ...[PostReplyedWidget(post: post), const SizedBox(height: 8)],

            PostHeaderWidget(post: post),
            PostBodyWidget(
              post: post,
              hasArabic: hasArabic,
              onComment: onComment,
              onLike: onLike,
              onRepost: onRepost,
              onShare: onShare,
            ),
          ],
        ),
      ),
    );
  }
}
