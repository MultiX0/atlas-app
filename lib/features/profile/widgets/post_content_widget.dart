import 'package:atlas_app/core/common/widgets/reuseable_comment_widget.dart';
import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';

class PostContentWidget extends ConsumerWidget {
  final String? hashtag;
  const PostContentWidget({super.key, required this.post, this.hashtag, this.repost = false});

  final bool repost;
  final PostModel post;
  bool get hasArabic => Bidi.hasAnyRtl(post.content);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: RepaintBoundary(
        child: CommentRichTextView(
          key: ValueKey(post.postId),
          text: post.content,
          maxLines: repost ? 3 : 20,
        ),
      ),
    );
  }
}
