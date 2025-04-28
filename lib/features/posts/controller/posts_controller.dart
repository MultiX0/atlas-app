// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:atlas_app/core/common/enum/post_like_enum.dart';
import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/extract_key_words.dart';
import 'package:atlas_app/core/common/utils/image_to_avif_convert.dart';
import 'package:atlas_app/core/common/utils/upload_storage.dart';
import 'package:atlas_app/core/common/widgets/slash_parser.dart';
import 'package:atlas_app/features/hashtags/providers/hashtag_state_provider.dart';
import 'package:atlas_app/features/hashtags/providers/providers.dart';
import 'package:atlas_app/features/novels/providers/novel_reviews_state.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/features/posts/db/posts_db.dart';
import 'package:atlas_app/features/posts/providers/main_feed_state.dart';
import 'package:atlas_app/features/posts/providers/providers.dart';
import 'package:atlas_app/features/profile/provider/profile_posts_state.dart';
import 'package:atlas_app/imports.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:uuid/uuid.dart';

final postsControllerProvider = StateNotifierProvider<PostsController, bool>((ref) {
  return PostsController(ref: ref);
});

class PostsController extends StateNotifier<bool> {
  // ignore: unused_field
  final Ref _ref;
  PostsController({required Ref ref}) : _ref = ref, super(false);

  PostsDb get db => _ref.watch(postsDbProvider);
  final uuid = const Uuid();

  Future<void> insertPost({
    required PostType postType,
    required String postContent,
    List<File>? images,
    required BuildContext context,
    required bool canRepost,
    required bool canComment,
  }) async {
    try {
      if (postContent.trim().isEmpty) context.pop();
      final user = _ref.read(userState).user!;
      final postId = uuid.v4();
      List<String>? links;
      context.loaderOverlay.show();
      if (images != null && images.isNotEmpty) {
        links = await uploadImages(postId: postId, userId: user.userId, images);
      }

      String? parentId;
      if (postType == PostType.repost) {
        final _id = _ref.read(selectedPostProvider);
        parentId = _id!.postId;
      }

      await db.insertPost(
        postId,
        postContent,
        user.userId,
        links,
        canComment: canComment,
        canRepost: canRepost,
        parentId: parentId,
      );
      if (postType == PostType.comic_review) {
        final review = _ref.read(selectedReview);
        await db.insertMentions([SlashEntity('comic_review', review!.id, 'Review')], postId);
        _ref.read(manhwaReviewsStateProvider(review.comicId).notifier).handleNewRepost(review);
      }

      if (postType == PostType.novel_review) {
        final review = _ref.read(selectedReview);
        await db.insertMentions([SlashEntity('novel_review', review!.id, 'Review')], postId);
        _ref.read(novelReviewsState(review.novelId).notifier).handleNewRepost(review);
      }

      if (postType == PostType.comic) {
        final comic = _ref.read(selectedComicProvider)!;
        await db.insertMentions([SlashEntity('comic', comic.comicId, 'Post')], postId);
      }

      if (postType == PostType.novel) {
        final novel = _ref.read(selectedNovelProvider)!;
        await db.insertMentions([SlashEntity('novel', novel.id, 'Novel')], postId);
      }

      await _ref.read(profilePostsStateProvider(user.userId).notifier).fetchData(refresh: true);
      context.loaderOverlay.hide();
      CustomToast.success("تم النشر");
      context.pop();
    } catch (e) {
      context.loaderOverlay.hide();
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updatePost({
    required PostModel originalPost,
    required String postContent,
    required BuildContext context,
    required bool canRepost,
    required bool canComment,
  }) async {
    try {
      final hashtags = extractHashtagKeyword(originalPost.content);
      final mentions = extractSlashKeywords(originalPost.content);

      final user = _ref.read(userState).user!;
      PostModel updatedPost = originalPost.copyWith(
        content: postContent,
        canReposted: canRepost,
        comments_open: canComment,
      );
      _ref.read(profilePostsStateProvider(user.userId).notifier).updatePost(updatedPost);
      context.loaderOverlay.show();
      await db.updatePost(updatedPost, hashtags, mentions);
      CustomToast.success("تم تحديث المنشور بنجاح");
      context.pop();
      context.loaderOverlay.hide();
    } catch (e) {
      context.loaderOverlay.hide();
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
          _ref.read(profilePostsStateProvider(post.userId).notifier).likePost(postModel: newPost);
          log("After state update: expecting userLiked = ${newPost.userLiked}");
          await db.handleUserLike(post, userId);
          _ref.read(hashtagStateProvider(post.userId).notifier).likePost(postModel: newPost);
          break;
        case PostLikeEnum.GENERAL:
          _ref.read(mainFeedStateProvider(post.userId).notifier).likePost(postModel: newPost);
          log("After state update: expecting userLiked = ${newPost.userLiked}");
          await db.handleUserLike(post, userId);
          _ref.read(mainFeedStateProvider(post.userId).notifier).likePost(postModel: newPost);
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
          _ref.read(hashtagStateProvider(post.userId).notifier).likePost(postModel: post);

          break;
        case PostLikeEnum.GENERAL:
          _ref.read(mainFeedStateProvider(post.userId).notifier).likePost(postModel: post);

          break;
      }
      rethrow;
    }
  }

  Future<void> handlePostPin(PostModel post) async {
    try {
      final me = _ref.read(userState.select((user) => user.user!));
      _ref.read(profilePostsStateProvider(me.userId).notifier).pinPost(post: post);
      await db.handlePostPin(post);
    } catch (e) {
      CustomToast.error(e);
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final me = _ref.read(userState.select((user) => user.user!));
      _ref.read(profilePostsStateProvider(me.userId).notifier).deletePost(postId);
      await db.deletePost(postId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handlePostSave(PostModel post) async {
    final me = _ref.read(userState.select((user) => user.user!));
    try {
      _ref
          .read(profilePostsStateProvider(post.userId).notifier)
          .updatePost(post.copyWith(isSaved: !post.isSaved));
      await db.handlePostSave(post, me.userId);
    } catch (e) {
      log(e.toString());
      _ref
          .read(profilePostsStateProvider(post.userId).notifier)
          .updatePost(post.copyWith(isSaved: post.isSaved));
      CustomToast.error(errorMsg);
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

  Future<List<String>> uploadImages(
    List<File> images, {
    required String postId,
    required String userId,
  }) async {
    try {
      const uuid = Uuid();
      String extension = '';
      List<String> _links = [];
      for (final image in images) {
        // Convert image to AVIF first
        final avifImage = await AvifConverter.convertToAvif(image, quality: 80);
        log("avifImage: ${avifImage?.absolute.path}");

        // Check if conversion was successful before proceeding
        if (avifImage != null) {
          extension = avifImage.absolute.path.split('.').last.trim().toString();
          final link = await UploadStorage.uploadImages(
            image: avifImage,
            path: 'posts/$postId/${uuid.v4()}.$extension',
          );
          log("avif image uploaded: $link");
          _links.add(link);
        } else {
          // If AVIF conversion fails, use the original image as fallback
          log('AVIF conversion failed for image. Using original format.');
          extension = image.absolute.path.split('.').last.trim().toString();
          final link = await UploadStorage.uploadImages(
            image: image,
            path: 'posts/$postId/${uuid.v4()}.$extension',
          );
          _links.add(link);
        }
      }
      return _links;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
