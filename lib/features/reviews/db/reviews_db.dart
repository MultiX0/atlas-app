import 'dart:convert';
import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/core/common/utils/encrypt.dart';
import 'package:atlas_app/core/common/widgets/slash_parser.dart';
import 'package:atlas_app/features/notifications/db/notifications_db.dart';
import 'package:atlas_app/features/novels/models/novel_review_model.dart';
import 'package:atlas_app/features/posts/db/posts_db.dart';
import 'package:atlas_app/imports.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

final reviewsDBProvider = Provider<ReviewsDb>((ref) {
  return ReviewsDb(ref: ref);
});

class ReviewsDb {
  // ignore: unused_field
  final Ref _ref;
  ReviewsDb({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _comicReviewsTable => _client.from(TableNames.comic_reviews);
  SupabaseQueryBuilder get _comicReviewLikesTable => _client.from(TableNames.comic_review_likes);
  SupabaseQueryBuilder get _comicReviewsView => _client.from(ViewNames.comic_reviews_with_likes);
  SupabaseQueryBuilder get _novelReviewsView => _client.from(ViewNames.novel_reviews_with_likes);
  SupabaseQueryBuilder get _novelReviewsTable => _client.from(TableNames.novel_reviews);
  SupabaseQueryBuilder get _novelReviewLikesTable => _client.from(TableNames.novel_review_likes);
  final uuid = const Uuid();
  static Dio get _dio => Dio();

  PostsDb get _postsDb => PostsDb();
  NotificationsDb get _notificationsDb => NotificationsDb();

  Future<void> insertComicReview(ComicReviewModel review, UserModel me) async {
    try {
      final postId = uuid.v4();
      final headers = await generateAuthHeaders();
      Map data = review.toMap();
      data['token'] = _client.auth.currentSession!.accessToken;
      await Future.wait([
        // _comicReviewsTable.insert(review.toMap()),
        _dio.post(
          '${appAPI}comic-review',
          options: Options(headers: headers),
          data: jsonEncode(data),
        ),
        _postsDb.insertPost(postId, review.review, me, []),
      ]);

      await _postsDb.insertMentions([SlashEntity('comic', review.comicId, "")], postId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertNovelReview(
    NovelReviewModel review,
    UserModel user,
    String novelAuthor,
  ) async {
    try {
      final postId = uuid.v4();
      final headers = await generateAuthHeaders();
      Map data = review.toMap();
      data['token'] = _client.auth.currentSession!.accessToken;

      await Future.wait([
        if (novelAuthor != user.userId)
          _notificationsDb.newNovelReviewNotification(
            novelAuthorId: novelAuthor,
            novelId: review.novelId,
            novelTitle: review.novelTitle,
            username: user.username,
            senderId: user.userId,
            reviewId: review.id,
          ),
        // _novelReviewsTable.insert(review.toMap()),
        _dio.post(
          '${appAPI}novel-review',
          options: Options(headers: headers),
          data: jsonEncode(data),
        ),

        _postsDb.insertPost(postId, review.review, user, []),
      ]);
      await _postsDb.insertMentions([SlashEntity('novel', review.novelId, "")], postId);
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
      final data = await _comicReviewsView
          .select("*")
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

  Future<bool> checkIhaveNovelReview({required String novelId}) async {
    try {
      return await _client.rpc(
        FunctionNames.has_user_reviewed_novel,
        params: {'p_novel_id': novelId},
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

  Future<int> getNovelReviewsCount(String novelId) async {
    try {
      final _count = await _client.rpc(
        FunctionNames.get_novel_review_count,
        params: {"p_novel_id": novelId},
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

  Future<AvgReviewsModel> getAvgNovelReviews(String novelId) async {
    try {
      final data = await _client.rpc(
        FunctionNames.get_novel_review_averages,
        params: {'p_novel_id': novelId},
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

  Future<void> updateNovelReview(NovelReviewModel review) async {
    try {
      await _novelReviewsTable
          .update(review.toMap())
          .eq(KeyNames.novel_id, review.novelId)
          .eq(KeyNames.userId, review.userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteNovelReview(NovelReviewModel review) async {
    try {
      await _novelReviewsTable
          .delete()
          .eq(KeyNames.novel_id, review.novelId)
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

  Future<void> handleComicReviewLike(ComicReviewModel review, String userId) async {
    try {
      if (review.i_liked) {
        await _comicReviewLikesTable.insert({
          KeyNames.review_id: review.id,
          KeyNames.userId: userId,
        });
      } else {
        await _comicReviewLikesTable
            .delete()
            .eq(KeyNames.userId, userId)
            .eq(KeyNames.review_id, review.id);
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleNovelReviewLike(NovelReviewModel review, UserModel user) async {
    try {
      if (review.i_liked) {
        await Future.wait([
          if (user.userId != review.userId)
            _notificationsDb.novelReviewLikeNotification(
              novelId: review.novelId,
              novelTitle: review.novelTitle,
              username: user.username,
              reviewAuthorId: review.userId,
              senderId: user.userId,
              reviewId: review.id,
            ),
          _novelReviewLikesTable.insert({
            KeyNames.review_id: review.id,
            KeyNames.userId: user.userId,
          }),
        ]);
      } else {
        await _novelReviewLikesTable
            .delete()
            .eq(KeyNames.userId, user.userId)
            .eq(KeyNames.review_id, review.id);
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<NovelReviewModel>> getNovelReviews({
    required String novelId,
    required int startIndex,
    required int pageSize,
  }) async {
    try {
      final data = await _novelReviewsView
          .select("*")
          .eq(KeyNames.novel_id, novelId)
          .order(KeyNames.created_at, ascending: false)
          .range(startIndex, startIndex + pageSize - 1);

      final reviews =
          data
              .map(
                (review) => NovelReviewModel.fromMap(
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
}
