import 'dart:async';
import 'dart:developer';

import 'package:atlas_app/core/common/enum/post_like_enum.dart';
import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/features/posts/controller/posts_controller.dart';
import 'package:atlas_app/features/profile/widgets/post_body_widget.dart';
import 'package:atlas_app/features/profile/widgets/post_header.dart';
import 'package:atlas_app/features/profile/widgets/post_replayed_widget.dart';
import 'package:atlas_app/features/profile/widgets/review_mentioned_widget.dart';
import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';

class PostWidget extends ConsumerWidget {
  PostWidget({
    super.key,
    required this.post,
    required this.onComment,
    required this.onRepost,
    required this.onShare,
    required this.postLikeType,
    this.hashtag,
  }) : hasArabic = Bidi.hasAnyRtl(post.content);

  final PostModel post;
  final bool hasArabic;
  final PostLikeEnum postLikeType;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;
  final String? hashtag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.read(userState.select((state) => state.user!));
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        child: Column(
          crossAxisAlignment: hasArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,

          children: [
            Divider(height: 0.25, color: AppColors.mutedSilver.withValues(alpha: .1)),
            const SizedBox(height: 15),
            if (post.parent != null) ...[PostReplyedWidget(post: post), const SizedBox(height: 8)],
            if (post.reviewMentioned != null) ...[
              ReviewMentionedWidget(post: post),
              const SizedBox(height: 8),
            ],

            PostHeaderWidget(post: post),
            PostBodyWidget(
              post: post,
              hashtag: hashtag,
              hasArabic: hasArabic,
              onComment: onComment,
              onLike: (_) => onLike(ref, me.userId),
              onRepost: onRepost,
              onShare: onShare,
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  final Debouncer _debouncer = Debouncer();
  Future<bool?> onLike(WidgetRef ref, String userId) async {
    log("liking...");
    _debouncer.debounce(
      duration: const Duration(milliseconds: 200),
      onDebounce: () async {
        await ref
            .read(postsControllerProvider.notifier)
            .likesMiddleware(userId: userId, post: post, postType: postLikeType);
      },
    );

    return true;
  }
}
