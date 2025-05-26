import 'dart:convert';
import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/core/common/enum/notificaion_type.dart';
import 'package:atlas_app/core/common/utils/encrypt.dart';
import 'package:atlas_app/features/notifications/interfaces/notifications_interface.dart';
import 'package:atlas_app/features/notifications/models/notification_container_model.dart';
import 'package:atlas_app/features/notifications/models/notification_event_model.dart';
import 'package:atlas_app/features/profile/db/profile_db.dart';
import 'package:atlas_app/imports.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class NotificationsDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _notificationsTable => _client.from(TableNames.notifications);
  SupabaseQueryBuilder get _notificationsView => _client.from(ViewNames.user_notifications_view);
  static Dio get _dio => Dio();
  ProfileDb get _profileDb => ProfileDb();
  String get token => _client.auth.currentSession!.accessToken;

  Future<void> sendNotificatiosn(NotificationContainerModel notification) async {
    try {
      final headers = await generateAuthHeaders();
      await _dio.post(
        "${appAPI}send-notification",
        options: Options(headers: headers),
        data: jsonEncode(notification.toMap()),
      );
    } catch (e) {
      log(e.toString());
      if (kDebugMode) {
        print(e);
      }
      //  dont throw  any errors
      return;
    }
  }

  Future<void> sendEvent(NotificationEventRequest event) async {
    try {
      final headers = await generateAuthHeaders();
      await _dio.post(
        "${appAPI}event",
        options: Options(headers: headers),
        data: jsonEncode(event.toJson()),
      );
    } catch (e) {
      log(e.toString());
      if (kDebugMode) {
        print(e);
      }
      //  dont throw  any errors
      return;
    }
  }

  Future<void> newNovelReviewNotification({
    required String novelTitle,
    required String novelAuthorId,
    required String username,
    required String novelId,
    required String senderId,
    required String reviewId,
  }) async {
    try {
      final notification = NotificationsInterface.novelReviewNotification(
        novelTitle: novelTitle,
        userId: novelAuthorId,
        username: username,
        data: {'route': '${Routes.novelPage}/$novelId'},
      );

      final event = NotificationEventRequest(
        recipientId: novelAuthorId,
        senderId: senderId,
        type: notificationEnumToString(NotificationType.newNovelReview),
        token: token,
        novelId: novelId,
        novelReviewId: reviewId,
      );

      await Future.wait([sendNotificatiosn(notification), sendEvent(event)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> novelReviewLikeNotification({
    required String novelTitle,
    required String reviewAuthorId,
    required String username,
    required String novelId,
    required String senderId,
    required String reviewId,
  }) async {
    try {
      final notification = NotificationsInterface.novelReviewLike(
        novelTitle: novelTitle,
        userId: reviewAuthorId,
        username: username,
        data: {'route': '${Routes.novelPage}/$novelId'},
      );

      final event = NotificationEventRequest(
        recipientId: reviewAuthorId,
        senderId: senderId,
        type: notificationEnumToString(NotificationType.novelReviewLike),
        token: token,
        novelId: novelId,
        novelReviewId: reviewId,
      );

      await Future.wait([sendNotificatiosn(notification), sendEvent(event)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> repostNotification({
    required String username,
    required String userId,
    required String senderId,
    required String postId,
  }) async {
    try {
      final notification = NotificationsInterface.postRepostNotification(
        userId: userId,
        username: username,
        data: {'route': '${Routes.postPage}/$postId'},
      );
      final event = NotificationEventRequest(
        recipientId: userId,
        senderId: senderId,
        type: notificationEnumToString(NotificationType.postRepost),
        token: token,
        postId: postId,
      );

      await Future.wait([sendNotificatiosn(notification), sendEvent(event)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> postLikeNotification({
    required String userId,
    required String username,
    required String postId,
    required String senderId,
  }) async {
    try {
      final notification = NotificationsInterface.postLikeNotification(
        userId: userId,
        username: username,
        data: {'route': '${Routes.postPage}/$postId'},
      );

      final event = NotificationEventRequest(
        recipientId: userId,
        senderId: senderId,
        type: notificationEnumToString(NotificationType.postLike),
        token: token,
        postId: postId,
      );

      await Future.wait([sendNotificatiosn(notification), sendEvent(event)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> novelChapterCommentReplyNotification({
    required String parentCommentAuthorId,
    required String username,
    required String novelTitle,
    required String senderId,
    required String novelId,
    required String chapterId,
    required String replyId,
  }) async {
    try {
      final notification = NotificationsInterface.novelChapterReplyCommentNotification(
        userId: parentCommentAuthorId,
        username: username,
        novelTitle: novelTitle,
        data: {'route': "${Routes.novelReadChapter}/$chapterId"},
      );

      final event = NotificationEventRequest(
        recipientId: parentCommentAuthorId,
        senderId: senderId,
        type: notificationEnumToString(NotificationType.novelChapterCommentReply),
        token: token,
        novelId: novelId,
        chapterId: chapterId,
        chapterReplyId: replyId,
      );

      await Future.wait([sendNotificatiosn(notification), sendEvent(event)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> novelChapterCommentNotification({
    required String username,
    required String authorId,
    required String novelId,
    required String senderId,
    required String chapterId,
    required String commentId,
  }) async {
    try {
      final notification = NotificationsInterface.novelChapterCommentNotification(
        userId: authorId,
        username: username,
        data: {'route': "${Routes.novelReadChapter}/$chapterId"},
      );

      final event = NotificationEventRequest(
        recipientId: authorId,
        senderId: senderId,
        type: notificationEnumToString(NotificationType.novelChapterComment),
        token: token,
        novelId: novelId,
        chapterId: chapterId,
        chapterCommentId: commentId,
      );

      await Future.wait([sendNotificatiosn(notification), sendEvent(event)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> addNovelToFavoriteNotification({
    required String authorId,
    required String username,
    required String senderId,
    required String novelId,
  }) async {
    try {
      final notification = NotificationsInterface.novelLikeNotification(
        userId: authorId,
        username: username,
        data: {'route': "${Routes.novelPage}/$novelId"},
      );
      final event = NotificationEventRequest(
        recipientId: authorId,
        senderId: senderId,
        type: notificationEnumToString(NotificationType.novelFavorite),
        token: token,
        novelId: novelId,
      );

      await Future.wait([sendNotificatiosn(notification), sendEvent(event)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> novelChapterLikeNotification({
    required String authorId,
    required String username,
    required String senderId,
    required String novelId,
    required String chapterId,
    required String novelTitle,
  }) async {
    try {
      final notification = NotificationsInterface.novelChapterLikeNotification(
        userId: authorId,
        username: username,
        data: {'route': "${Routes.novelReadChapter}/$chapterId"},

        novelTitle: novelTitle,
      );
      final event = NotificationEventRequest(
        recipientId: authorId,
        senderId: senderId,
        type: notificationEnumToString(NotificationType.novelChapterLike),
        token: token,
        chapterId: chapterId,
        novelId: novelId,
      );

      await Future.wait([sendNotificatiosn(notification), sendEvent(event)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> novelChapterLikeCommentNotification({
    required String commentOwnerId,
    required String username,
    required String novelId,
    required String senderId,
    required String chapterId,
    required String novelTitle,
  }) async {
    try {
      final notification = NotificationsInterface.novelChapterLikeCommentNotification(
        userId: commentOwnerId,
        username: username,
        data: {'route': "${Routes.novelReadChapter}/$chapterId"},

        novelTitle: novelTitle,
      );
      final event = NotificationEventRequest(
        recipientId: commentOwnerId,
        senderId: senderId,
        type: notificationEnumToString(NotificationType.novelChapterCommentLike),
        token: token,
        chapterId: chapterId,
        novelId: novelId,
      );

      await Future.wait([sendNotificatiosn(notification), sendEvent(event)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> userFollowNotification({
    required String targetId,
    required String username,
    required String userId,
  }) async {
    try {
      final notification = NotificationsInterface.followUserNotification(
        userId: targetId,
        username: username,
        data: {'route': '${Routes.user}/$userId'},
      );

      final event = NotificationEventRequest(
        recipientId: targetId,
        senderId: userId,
        type: notificationEnumToString(NotificationType.follow),
        token: token,
      );

      await Future.wait([sendNotificatiosn(notification), sendEvent(event)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> postCommentLikeNotification({
    required String ownerId,
    required String postAuthorName,
    required String username,
    required String senderId,
    required String postId,
    required String commentId,
  }) async {
    try {
      final notification = NotificationsInterface.postLikeCommentNotification(
        userId: ownerId,
        username: username,
        postTitle: postAuthorName,
        data: {'route': '${Routes.postPage}/$postId'},
      );
      final event = NotificationEventRequest(
        recipientId: ownerId,
        senderId: senderId,
        postCommentId: commentId,
        postId: postId,
        type: notificationEnumToString(NotificationType.commentLike),
        token: token,
      );

      await Future.wait([sendNotificatiosn(notification), sendEvent(event)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> postCommentReplyLikeNotification({
    required String ownerId,
    required String postAuthorName,
    required String username,
    required String senderId,
    required String postId,
    required String commentId,
    required String replyId,
  }) async {
    try {
      final notification = NotificationsInterface.postLikeCommentNotification(
        userId: ownerId,
        username: username,
        postTitle: postAuthorName,
        data: {'route': '${Routes.postPage}/$postId'},
      );
      final event = NotificationEventRequest(
        recipientId: ownerId,
        senderId: senderId,
        postCommentId: commentId,
        postId: postId,
        postReplyId: replyId,
        type: notificationEnumToString(NotificationType.replyLike),
        token: token,
      );

      await Future.wait([sendNotificatiosn(notification), sendEvent(event)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> postCommentReplyNotification({
    required String parentAuthorId,
    required String username,
    required String senderId,
    required String postId,
    required String commentId,
    required String replyId,
  }) async {
    try {
      final notification = NotificationsInterface.commentReplyNotification(
        userId: parentAuthorId,
        username: username,
        data: {'route': '${Routes.postPage}/$postId'},
      );
      final event = NotificationEventRequest(
        recipientId: parentAuthorId,
        senderId: senderId,
        postCommentId: commentId,
        postId: postId,
        postReplyId: replyId,
        type: notificationEnumToString(NotificationType.postCommentReply),
        token: token,
      );

      await Future.wait([sendNotificatiosn(notification), sendEvent(event)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> postCommentNotification({
    required String username,
    required String senderId,
    required String postId,
    required String commentId,
    required String ownerId,
  }) async {
    try {
      final notification = NotificationsInterface.postCommentNotification(
        userId: ownerId,
        username: username,
        data: {'route': '${Routes.postPage}/$postId'},
      );
      final event = NotificationEventRequest(
        recipientId: ownerId,
        senderId: senderId,
        postCommentId: commentId,
        postId: postId,
        type: notificationEnumToString(NotificationType.postComment),
        token: token,
      );

      await Future.wait([sendNotificatiosn(notification), sendEvent(event)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> sendMentionNotifications(List<String> mentions, String type, UserModel me) async {
    try {
      NotificationContainerModel notification;

      switch (type.trim()) {
        case 'pc':
          notification = NotificationsInterface.userMentionedInComment(
            userId: '',
            username: me.username,
          );
          break;

        case 'cc':
          notification = NotificationsInterface.userMentionedInChapterComment(
            userId: '',
            username: me.username,
          );
          break;
        default:
          notification = NotificationsInterface.userMentionedInPost(
            userId: '',
            username: me.username,
          );
      }
      final data = await Future.wait<dynamic>([
        generateAuthHeaders(),
        _profileDb.getUserIdBasedOnUsername(mentions),
      ]);
      final [headers, users] = data;
      final body = jsonEncode({
        'title': notification.title,
        'body': notification.body,
        'ids': users,
      });
      await _dio.post(
        "${appAPI}send-notification-batch",
        options: Options(headers: headers),
        data: body,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Stream<int> getUnreadedNotificationsCount(String userId) {
    try {
      return _notificationsTable
          .stream(primaryKey: [KeyNames.id])
          .eq(KeyNames.recipient_id, userId)
          .order(KeyNames.created_at, ascending: false)
          .limit(10)
          .asyncMap((data) {
            return data.where((d) => d[KeyNames.is_read] == false).toList().length;
          })
          .debounceTime(const Duration(milliseconds: 500))
          .asBroadcastStream();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<NotificationEventRequest>> getUserNotifications(String userId) async {
    try {
      final data = await _notificationsView
          .select("*")
          .eq(KeyNames.recipient_id, userId)
          .order(KeyNames.created_at, ascending: false);

      return data.map((n) => NotificationEventRequest.fromJson(n)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client.rpc(
        FunctionNames.mark_notification_as_read,
        params: {'target_notification_id': notificationId},
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
