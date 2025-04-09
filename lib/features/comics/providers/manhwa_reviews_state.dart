// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:atlas_app/features/auth/providers/user_state.dart';
import 'package:atlas_app/features/reviews/db/reviews_db.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:atlas_app/features/reviews/models/comic_review_model.dart';

class ManhwaReviewsHelper {
  final List<ComicReviewModel> reviews;
  final String? error;
  final bool isLoading;
  final bool hasReachedEnd;
  final bool moreLoading;
  final int reviewsCount;
  final bool user_have_review_before;
  ManhwaReviewsHelper({
    required this.reviews,
    this.error,
    required this.isLoading,
    required this.hasReachedEnd,
    required this.reviewsCount,
    required this.moreLoading,
    required this.user_have_review_before,
  });

  ManhwaReviewsHelper copyWith({
    List<ComicReviewModel>? reviews,
    int? reviewsCount,
    String? error,
    bool? isLoading,
    bool? hasReachedEnd,
    bool? moreLoading,
    bool? user_have_review_before,
  }) {
    return ManhwaReviewsHelper(
      reviews: reviews ?? this.reviews,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      moreLoading: moreLoading ?? this.moreLoading,
      user_have_review_before: user_have_review_before ?? this.user_have_review_before,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }
}

class ManhwaReviewsState extends StateNotifier<ManhwaReviewsHelper> {
  final Ref _ref;
  final String _comicId;
  ManhwaReviewsState({required Ref ref, required String comicId})
    : _ref = ref,
      _comicId = comicId,
      super(
        ManhwaReviewsHelper(
          isLoading: false,
          user_have_review_before: false,
          moreLoading: false,
          reviews: [],
          error: null,
          hasReachedEnd: false,
          reviewsCount: 0,
        ),
      );

  ReviewsDb get _db => _ref.watch(reviewsDBProvider);

  void updateState({
    bool? isLoading,
    String? error,
    bool? moreLoading,
    List<ComicReviewModel>? reviews,
    bool? hasReachEnd,
    bool? user_have_review_before,
    int? reviewsCount,
  }) {
    state = state.copyWith(
      isLoading: isLoading ?? state.isLoading,
      error: error ?? state.error,
      user_have_review_before: user_have_review_before ?? state.user_have_review_before,
      moreLoading: moreLoading ?? state.moreLoading,
      reviews: reviews ?? state.reviews,
      hasReachedEnd: hasReachEnd ?? state.hasReachedEnd,
      reviewsCount: reviewsCount ?? state.reviewsCount,
    );
  }

  void clearState() {
    log("clearing reviews state...");
    state = ManhwaReviewsHelper(
      reviewsCount: 0,
      isLoading: false,
      user_have_review_before: false,
      moreLoading: false,
      reviews: [],
      error: null,
      hasReachedEnd: false,
    );
  }

  Future<void> fetchReviews({bool refresh = false}) async {
    try {
      log("reviews fetching function");

      // If we're already loading or we've reached the end and we're not refreshing, don't fetch

      if ((state.isLoading || state.hasReachedEnd) && !refresh) {
        log("empty state and we reach the end");
        updateState(error: null, moreLoading: false, isLoading: false);
        return;
      }

      if (state.reviews.isEmpty || refresh) {
        updateState(error: null, moreLoading: false, isLoading: true);
      }

      if (state.reviewsCount == 0 || refresh) {
        final count = await _db.getManhwaReviewsCount(_comicId);
        updateState(reviewsCount: count);
      }

      if (!state.user_have_review_before) {
        final me = _ref.read(userState).user!;
        final reviewd = await _db.checkIhaveReview(userId: me.userId, comicId: _comicId);
        updateState(user_have_review_before: reviewd);
      }

      log("fetching reviews.......");
      const _pageSize = 20;
      final startIndex = refresh ? 0 : state.reviews.length;
      final reviews = await _db.getComicReviews(
        comicId: _comicId,
        startIndex: startIndex,
        pageSize: _pageSize,
      );

      final hasReachedEnd = reviews.length < _pageSize;
      updateState(
        moreLoading: false,
        hasReachEnd: hasReachedEnd,
        error: null,
        isLoading: false,
        reviews: reviews,
      );
    } catch (e) {
      updateState(isLoading: false, error: e.toString());
      log(e.toString());
      rethrow;
    }
  }

  void refresh(String comicId) {
    fetchReviews(refresh: true);
  }

  void addReview(ComicReviewModel review) {
    List<ComicReviewModel> newReivews = List.from(state.reviews);
    newReivews.add(review);
    newReivews.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    updateState(reviews: newReivews, reviewsCount: state.reviewsCount + 1);
  }
}

final manhwaReviewsStateProvider =
    StateNotifierProvider.family<ManhwaReviewsState, ManhwaReviewsHelper, String>((ref, comicId) {
      return ManhwaReviewsState(ref: ref, comicId: comicId);
    });
