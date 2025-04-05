import 'dart:developer';

import 'package:atlas_app/core/common/constants/table_names.dart';
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
}
