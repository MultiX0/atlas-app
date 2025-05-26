import 'dart:async';
import 'dart:developer';

import 'package:atlas_app/core/common/enum/post_like_enum.dart';
import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/features/posts/controller/posts_controller.dart';
import 'package:atlas_app/features/posts/db/posts_db.dart';
import 'package:atlas_app/features/posts/providers/post_state.dart';
import 'package:atlas_app/features/profile/provider/providers.dart';
import 'package:atlas_app/features/profile/widgets/post_body_widget.dart';
import 'package:atlas_app/features/profile/widgets/post_header.dart';
import 'package:atlas_app/features/profile/widgets/post_replayed_widget.dart';
import 'package:atlas_app/features/profile/widgets/review_mentioned_widget.dart';
import 'package:atlas_app/imports.dart';
import 'package:atlas_app/router.dart';
import 'package:intl/intl.dart';

class PostWidget extends ConsumerWidget {
  PostWidget({
    super.key,
    required this.post,
    required this.onShare,
    required this.postLikeType,
    this.profileNav = true,

    this.hashtag,
  }) : hasArabic = Bidi.hasAnyRtl(post.content);

  final PostModel post;
  final bool hasArabic;
  final bool profileNav;
  final PostLikeEnum postLikeType;
  final VoidCallback? onShare;
  final String? hashtag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.read(userState.select((state) => state.user!));
    final postRoute = (ref.read(routerProvider).state.fullPath ?? "").contains(Routes.postPage);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          ref.read(postsDbProvider).seePost(post.postId, me.userId);
          onComment(context, postRoute, ref: ref);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          child: Column(
            crossAxisAlignment: hasArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,

            children: [
              Divider(height: 0.25, color: AppColors.mutedSilver.withValues(alpha: .1)),
              const SizedBox(height: 15),
              if (post.parent != null) ...[
                InkWell(
                  onTap: () {
                    ref.read(postStateProvider.notifier).updatePost(post);
                    ref.read(selectedPostLikeTypeProvider.notifier).state = postLikeType;
                    context.push("${Routes.postPage}/${post.parent!.postId}");
                  },
                  child: PostReplyedWidget(post: post),
                ),
                const SizedBox(height: 8),
              ],
              if (post.comicReviewMentioned != null || post.novelReviewMentioned != null) ...[
                ReviewMentionedWidget(post: post),
                const SizedBox(height: 8),
              ],

              PostHeaderWidget(post: post, profileNav: profileNav, postType: postLikeType),
              PostBodyWidget(
                post: post,
                hashtag: hashtag,
                hasArabic: hasArabic,
                onComment: () {
                  ref.read(postsDbProvider).seePost(post.postId, me.userId);
                  onComment(context, postRoute, ref: ref);
                },
                onLike: (_) => onLike(ref, me.userId),
                onRepost: () => onRepost(ref),
                onShare: onShare,
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  void onComment(
    BuildContext context,
    bool postRoute, {
    required WidgetRef ref,
    bool commentPage = false,
  }) {
    if (postRoute) return;
    if (commentPage) {
      CustomToast.error("التعليقات مغلقة لهذا المنشور");
      return;
    }
    ref.read(postStateProvider.notifier).updatePost(post);
    ref.read(selectedPostLikeTypeProvider.notifier).state = postLikeType;
    context.push("${Routes.postPage}/${post.postId}");
  }

  void onRepost(WidgetRef ref) {
    ref.read(selectedPostProvider.notifier).state = post;
    ref.read(navsProvider).goToMakePostPage(PostType.repost);
  }

  final Debouncer _debouncer = Debouncer();
  Future<bool?> onLike(WidgetRef ref, String userId) async {
    log("liking...");
    _debouncer.debounce(
      duration: const Duration(milliseconds: 200),
      onDebounce: () async {
        final result = await ref
            .read(postsControllerProvider.notifier)
            .likesMiddleware(post: post, postType: postLikeType);
        return result;
      },
    );

    return true;
  }
}
