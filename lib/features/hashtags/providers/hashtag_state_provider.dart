// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:atlas_app/core/common/enum/hashtag_enum.dart';
import 'package:atlas_app/features/hashtags/db/hashtags_db.dart';
import 'package:atlas_app/features/hashtags/models/hashtag_model.dart';
import 'package:atlas_app/features/posts/db/posts_db.dart';
import 'package:atlas_app/features/posts/models/post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HashtagStateHelper {
  final HashtagModel? hashtag;
  final List<PostModel> posts;
  final bool isLoading;
  final bool isLiking;
  final bool loadingMore;
  final String? error;
  final bool hasReachedEnd;
  HashtagStateHelper({
    this.hashtag,
    required this.posts,
    required this.isLoading,
    required this.loadingMore,
    required this.hasReachedEnd,
    required this.isLiking,
    this.error,
  });

  HashtagStateHelper copyWith({
    HashtagModel? hashtag,
    List<PostModel>? posts,
    bool? isLoading,
    bool? loadingMore,
    String? error,
    bool? hasReachedEnd,
    bool? isLiking,
  }) {
    return HashtagStateHelper(
      hashtag: hashtag ?? this.hashtag,
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error ?? this.error,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLiking: isLiking ?? this.isLiking,
    );
  }
}

class HashtagStateProvider extends StateNotifier<HashtagStateHelper> {
  static final emptyState = HashtagStateHelper(
    hasReachedEnd: false,
    posts: [],
    isLoading: true,
    loadingMore: false,
    isLiking: false,
  );
  // ignore: unused_field
  final Ref _ref;
  final String _hashtag;
  HashtagStateProvider({required Ref ref, required String hashtag})
    : _hashtag = hashtag,
      _ref = ref,
      super(emptyState);

  PostsDb get _postsDb => PostsDb();
  HashtagsDb get _hashtagsDb => HashtagsDb();

  void updateState({
    HashtagModel? hashtag,
    List<PostModel>? posts,
    bool? isLoading,
    bool? loadingMore,
    String? error,
    bool? hasReachedEnd,
  }) {
    state = state.copyWith(
      hashtag: hashtag ?? state.hashtag,
      posts: posts ?? state.posts,
      isLoading: isLoading ?? state.isLoading,
      loadingMore: loadingMore ?? state.loadingMore,
      error: error ?? state.error,
      hasReachedEnd: hasReachedEnd ?? state.hasReachedEnd,
    );
  }

  Future<void> fetchHashtag() async {
    try {
      final hashtag = await _hashtagsDb.getHashtag(_hashtag);
      log("hashtag: $hashtag");
      updateState(hashtag: hashtag);
    } catch (e) {
      updateState(error: e.toString());
      log(e.toString());
      rethrow;
    }
  }

  Future<void> fetchData({
    bool refresh = false,
    HashtagFilter filter = HashtagFilter.LAST_CREATED,
  }) async {
    try {
      if (state.isLiking) {
        log("Skipping fetch: like action in progress");
        return;
      }
      updateState(error: null);
      log("Fetching hashtags data for hashtag: $_hashtag, refresh: $refresh");

      if (state.posts.isEmpty || refresh) {
        updateState(error: null, isLoading: true);
        await fetchHashtag();
      } else {
        updateState(error: null, loadingMore: true, isLoading: false);
      }

      const _pageSize = 15;
      final startIndex = refresh ? 0 : state.posts.length;
      log("Fetching posts with startIndex: $startIndex, pageSize: $_pageSize");

      final newPosts = await _postsDb.getPostsByHashtag(
        hashtag: _hashtag,
        filter: filter,
        startIndex: startIndex,
        pageSize: _pageSize,
      );

      log("Fetched ${newPosts.length} posts: ${newPosts.map((p) => p.postId).toList()}");

      final hasReachedEnd = newPosts.length < _pageSize;
      final updatedPosts = refresh ? newPosts : [...state.posts, ...newPosts];

      updateState(
        loadingMore: false,
        hasReachedEnd: hasReachedEnd,
        error: null,
        isLoading: false,
        posts: updatedPosts,
      );
      log(
        "fetchData completed, updated posts: ${state.posts.map((p) => "${p.postId}: ${p.userLiked}").toList()}",
      );
    } catch (e) {
      log("fetchData error: $e");
      updateState(isLoading: false, loadingMore: false, error: e.toString());
    }
  }

  void likePost({required PostModel postModel}) {
    state = state.copyWith(isLiking: true);
    log("Updating post like state: ${postModel.postId}, userLiked: ${postModel.userLiked}");

    final posts = List<PostModel>.from(state.posts);
    final indexOfPost = posts.indexWhere((post) => post.postId == postModel.postId);

    if (indexOfPost == -1) {
      log("Post not found in state: ${postModel.postId}");
      return;
    }

    // Replace with the updated post
    posts[indexOfPost] = postModel;
    state = state.copyWith(posts: posts);
    state = state.copyWith(isLiking: false);
  }
}

final hashtagStateProvider =
    StateNotifierProvider.family<HashtagStateProvider, HashtagStateHelper, String>((ref, hashtag) {
      log("state notifier on value: $hashtag");
      return HashtagStateProvider(ref: ref, hashtag: hashtag);
    });
