import 'dart:developer';

import 'package:atlas_app/core/common/enum/post_like_enum.dart';
import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/features/hashtags/providers/hashtag_state_provider.dart';
import 'package:atlas_app/features/hashtags/providers/providers.dart';
import 'package:atlas_app/features/posts/db/posts_db.dart';
import 'package:atlas_app/imports.dart';

final postsControllerProvider = StateNotifierProvider<PostsController, bool>((ref) {
  return PostsController(ref: ref);
});

final getUserPostsProvider = FutureProvider.family<List<PostModel>, String>((ref, userId) async {
  final controller = ref.watch(postsControllerProvider.notifier);
  return await controller.getUserPosts(userId);
});

class PostsController extends StateNotifier<bool> {
  // ignore: unused_field
  final Ref _ref;
  PostsController({required Ref ref}) : _ref = ref, super(false);

  PostsDb get db => _ref.watch(postsDbProvider);

  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      return await db.getUserPosts(userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> likesMiddleware({
    required String userId,
    required PostModel post,
    required PostLikeEnum postType,
  }) async {
    try {
      log("Before update: post.userLiked = ${post.userLiked}");
      final hashtag = _ref.read(selectedHashtagProvider);
      final newPost = post.copyWith(
        userLiked: !post.userLiked,
        likeCount: !post.userLiked ? post.likeCount + 1 : post.likeCount - 1,
      );
      switch (postType) {
        case PostLikeEnum.HASHTAG:
          _ref.read(hashtagStateProvider(hashtag).notifier).likePost(postModel: newPost);
          log("After state update: expecting userLiked = ${newPost.userLiked}");
          await db.handleUserLike(post, userId);
          _ref.read(hashtagStateProvider(hashtag).notifier).likePost(postModel: newPost);
          break;
        case PostLikeEnum.PROFILE:
          break;
        case PostLikeEnum.GENERAL:
          break;
      }
    } catch (e) {
      CustomToast.error(errorMsg);
      log(e.toString());
      switch (postType) {
        case PostLikeEnum.HASHTAG:
          _ref
              .read(hashtagStateProvider(_ref.read(selectedHashtagProvider)).notifier)
              .likePost(postModel: post);
          break;
        case PostLikeEnum.PROFILE:
          break;
        case PostLikeEnum.GENERAL:
          break;
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> slashMentionSearch(String query) async {
    try {
      return await db.slashMentionSearch(query);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
