// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_element, library_private_types_in_public_api
import 'dart:developer';

import 'package:atlas_app/features/posts/db/posts_db.dart';
import 'package:atlas_app/imports.dart';

class _HelperClass {
  final List<PostModel> posts;
  final String? error;
  final bool isLoading;
  final bool loadingMore;
  final bool hasReachedEnd;
  final int currentPage;
  _HelperClass({
    required this.posts,
    this.error,
    required this.isLoading,
    required this.loadingMore,
    required this.currentPage,
    required this.hasReachedEnd,
  });

  _HelperClass copyWith({
    List<PostModel>? posts,
    String? error,
    bool? isLoading,
    bool? loadingMore,
    int? currentPage,
    bool? hasReachedEnd,
  }) {
    return _HelperClass(
      posts: posts ?? this.posts,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class MainFeedState extends StateNotifier<_HelperClass> {
  static _HelperClass get empty => _HelperClass(
    posts: [],
    isLoading: true,
    loadingMore: false,
    hasReachedEnd: false,
    currentPage: 1,
  );

  final Ref _ref;
  final String _userId;

  MainFeedState({required Ref ref, required String userId})
    : _ref = ref,
      _userId = userId,
      super(empty);

  PostsDb get _db => _ref.watch(postsDbProvider);

  void updateState({
    List<PostModel>? posts,
    bool? isLoading,
    bool? loadingMore,
    String? error,
    bool? hasReachedEnd,
    int? currentPage,
  }) {
    state = state.copyWith(
      posts: posts ?? state.posts,
      isLoading: isLoading ?? state.isLoading,
      loadingMore: loadingMore ?? state.loadingMore,
      error: error ?? state.error,
      hasReachedEnd: hasReachedEnd ?? state.hasReachedEnd,
      currentPage: currentPage ?? state.currentPage,
    );
  }

  Future<void> fetchData({bool refresh = false}) async {
    try {
      if (state.loadingMore) return;

      if (!refresh && state.hasReachedEnd) {
        log("reach end of the data");
        return;
      }

      if (state.posts.isEmpty || refresh) {
        updateState(error: null, isLoading: true);
      } else {
        updateState(error: null, loadingMore: true, isLoading: false);
      }

      const _pageSize = 20;
      final currentPage = refresh ? 1 : state.currentPage;
      final startIndex = refresh ? 0 : state.posts.length;
      final posts = await _db.getMainFeeds(
        userId: _userId,
        page: currentPage,
        startAt: startIndex,
        pageSize: _pageSize,
      );

      final updatedposts = refresh ? posts : [...state.posts, ...posts];
      final newPageNumber = refresh ? 1 : state.currentPage + 1;

      updateState(
        loadingMore: false,
        hasReachedEnd: false,
        error: null,
        isLoading: false,
        currentPage: newPageNumber,
        posts: updatedposts,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  void likePost({required PostModel postModel}) {
    log("Updating post like state: ${postModel.postId}, userLiked: ${postModel.userLiked}");

    final posts = List<PostModel>.from(state.posts);
    List<int> indexes =
        posts
            .asMap()
            .entries
            .where((entry) => entry.value.postId == postModel.postId)
            .map((entry) => entry.key)
            .toList();

    // FIX: Change `isNotEmpty` to `isEmpty`
    if (indexes.isEmpty) {
      log("Post with ID ${postModel.postId} not found in state, cannot update.");
      return;
    }

    // Replace with the updated post
    for (int index in indexes) {
      posts[index] = postModel;
    }

    state = state.copyWith(posts: posts);
    log("Post with ID ${postModel.postId} updated successfully.");
  }

  void updatePost(PostModel post) {
    List<PostModel> updatedPosts = List<PostModel>.from(state.posts);

    List<int> indexes =
        updatedPosts
            .asMap()
            .entries
            .where((entry) => entry.value.postId == post.postId)
            .map((entry) => entry.key)
            .toList();
    if (indexes.isEmpty) return;
    for (final index in indexes) {
      updatedPosts[index] = post;
    }
    state = state.copyWith(posts: updatedPosts);
  }
}

final mainFeedStateProvider = StateNotifierProvider.family<MainFeedState, _HelperClass, String>((
  ref,
  userId,
) {
  return MainFeedState(ref: ref, userId: userId);
});
