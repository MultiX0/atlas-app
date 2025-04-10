import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/features/reviews/models/avg_reviews_model.dart';
import 'package:atlas_app/features/reviews/models/comic_review_model.dart';
import 'package:atlas_app/imports.dart';

final reviewsDBProvider = Provider<ReviewsDb>((ref) {
  return ReviewsDb(ref: ref);
});

class ReviewsDb {
  // ignore: unused_field
  final Ref _ref;
  ReviewsDb({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _comicReviewsTable => _client.from(TableNames.comic_reviews);

  Future<void> insertComicReview(ComicReviewModel review) async {
    try {
      await _comicReviewsTable.insert(review.toMap());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<ComicReviewModel>> getComicReviews({
    required String comicId,
    required int startIndex,
    required int pageSize,
  }) async {
    try {
      final data = await _comicReviewsTable
          .select("*,${TableNames.users}(*)")
          .eq(KeyNames.comic_id, comicId)
          .order(KeyNames.created_at, ascending: false)
          .range(startIndex, startIndex + pageSize - 1);

      final reviews =
          data
              .map(
                (review) => ComicReviewModel.fromMap(
                  review,
                ).copyWith(user: UserModel.fromMap(review[TableNames.users])),
              )
              .toList();
      return reviews;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<bool> checkIhaveComicReview({required String userId, required String comicId}) async {
    try {
      return await _client.rpc(
        FunctionNames.check_if_review_before,
        params: {'p_comic_id': comicId, 'p_user_id': userId},
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<int> getManhwaReviewsCount(String comicId) async {
    try {
      final _count = await _client.rpc(
        FunctionNames.get_comic_review_count,
        params: {"p_comic_id": comicId},
      );
      return _count;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<AvgReviewsModel> getAvgComicReviews(String comicId) async {
    try {
      final data = await _client.rpc(
        FunctionNames.get_comic_avg_ratings,
        params: {'p_comic_id': comicId},
      );

      final response = data[0];

      final parsedData = {
        KeyNames.writing_quality_avg: response[KeyNames.writing_quality_avg],
        KeyNames.story_development_avg: response[KeyNames.story_development_avg],
        KeyNames.character_design_avg: response[KeyNames.character_design_avg],
        KeyNames.update_stability_avg: response[KeyNames.update_stability_avg],
        KeyNames.world_background_avg: response[KeyNames.world_background_avg],
        KeyNames.overall_avg: response[KeyNames.overall_avg],
      };

      return AvgReviewsModel.fromMap(Map.from(parsedData));
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updateComicReview(ComicReviewModel review) async {
    try {
      await _comicReviewsTable
          .update(review.toMap())
          .eq(KeyNames.comic_id, review.comicId)
          .eq(KeyNames.userId, review.userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteComicReview(ComicReviewModel review) async {
    try {
      await _comicReviewsTable
          .delete()
          .eq(KeyNames.comic_id, review.comicId)
          .eq(KeyNames.userId, review.userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
