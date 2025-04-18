// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:atlas_app/features/hashtags/models/hashtag_model.dart';
import 'package:atlas_app/features/posts/db/posts_db.dart';
import 'package:atlas_app/features/posts/models/post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePostsStateHelper {
  final List<PostModel> posts;
  final bool isLoading;
  final bool isLiking;
  final bool loadingMore;
  final String? error;
  final bool hasReachedEnd;
  ProfilePostsStateHelper({
    required this.posts,
    required this.isLoading,
    required this.loadingMore,
    required this.hasReachedEnd,
    required this.isLiking,
    this.error,
  });

  ProfilePostsStateHelper copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? loadingMore,
    String? error,
    bool? hasReachedEnd,
    bool? isLiking,
  }) {
    return ProfilePostsStateHelper(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error ?? this.error,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLiking: isLiking ?? this.isLiking,
    );
  }
}

class ProfilePostsStateProvider extends StateNotifier<ProfilePostsStateHelper> {
  static final emptyState = ProfilePostsStateHelper(
    hasReachedEnd: false,
    posts: [],
    isLoading: true,
    loadingMore: false,
    isLiking: false,
  );
  // ignore: unused_field
  final Ref _ref;
  final String _userId;
  ProfilePostsStateProvider({required Ref ref, required String userId})
    : _userId = userId,
      _ref = ref,
      super(emptyState);

  PostsDb get _postsDb => PostsDb();

  void updateState({
    HashtagModel? hashtag,
    List<PostModel>? posts,
    bool? isLoading,
    bool? loadingMore,
    String? error,
    bool? hasReachedEnd,
  }) {
    state = state.copyWith(
      posts: posts ?? state.posts,
      isLoading: isLoading ?? state.isLoading,
      loadingMore: loadingMore ?? state.loadingMore,
      error: error ?? state.error,
      hasReachedEnd: hasReachedEnd ?? state.hasReachedEnd,
    );
  }

  Future<void> fetchData({bool refresh = false}) async {
    try {
      if (state.isLiking) {
        log("Skipping fetch: like action in progress");
        return;
      }
      updateState(error: null);

      if (state.posts.isEmpty || refresh) {
        updateState(error: null, isLoading: true);
      } else {
        updateState(error: null, loadingMore: true, isLoading: false);
      }

      const _pageSize = 15;
      final startIndex = refresh ? 0 : state.posts.length;
      log("Fetching posts with startIndex: $startIndex, pageSize: $_pageSize");

      final newPosts = await _postsDb.getUserPosts(
        userId: _userId,
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

  void newPost({required PostModel post}) {
    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts.insert(0, post);
    state = state.copyWith(posts: updatedPosts);
  }
}

final profilePostsStateProvider =
    StateNotifierProvider.family<ProfilePostsStateProvider, ProfilePostsStateHelper, String>((
      ref,
      userId,
    ) {
      log("state notifier on value: $userId");
      return ProfilePostsStateProvider(ref: ref, userId: userId);
    });
