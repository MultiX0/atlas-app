import 'package:atlas_app/features/notifications/models/notification_container_model.dart';

class NotificationsInterface {
  static NotificationContainerModel postLikeNotification({
    required String userId,
    Map<String, dynamic>? data,
    required String username,
  }) => NotificationContainerModel(
    title: "أعجب بمنشورك",
    body: 'قام $username بالإعجاب بمنشورك. ألقِ نظرة!',
    userId: userId,
    data: data,
  );

  static NotificationContainerModel userMentionedInPost({
    required String userId,
    Map<String, dynamic>? data,
    required String username,
  }) => NotificationContainerModel(
    title: "تم الإشارة إليك في منشور",
    body: 'قام $username بالإشارة إليك في منشور. تحقق منه الآن!',
    userId: userId,
    data: data,
  );

  static NotificationContainerModel userMentionedInComment({
    required String userId,
    Map<String, dynamic>? data,
    required String username,
  }) => NotificationContainerModel(
    title: "تم الإشارة إليك في تعليق",
    body: 'قام $username بالإشارة إليك في تعليق. ألقِ نظرة!',
    userId: userId,
    data: data,
  );

  static NotificationContainerModel userMentionedInChapterComment({
    required String userId,
    Map<String, dynamic>? data,
    required String username,
  }) => NotificationContainerModel(
    title: "تم الإشارة إليك في تعليق على فصل رواية",
    body: 'قام $username بالإشارة إليك في تعليق على فصل رواية. تحقق منه!',
    userId: userId,
    data: data,
  );

  static NotificationContainerModel novelLikeNotification({
    required String userId,
    Map<String, dynamic>? data,
    required String username,
  }) => NotificationContainerModel(
    title: "إعجاب بروايتك",
    body: 'أُعجب $username بروايتك. جميل جداً!',
    userId: userId,
    data: data,
  );

  static NotificationContainerModel novelChapterCommentNotification({
    required String userId,
    Map<String, dynamic>? data,
    required String username,
  }) => NotificationContainerModel(
    title: "تعليق على فصل روايتك",
    body: 'قام $username بكتابة تعليق على أحد فصول روايتك. تحقق منه!',
    userId: userId,
    data: data,
  );

  static NotificationContainerModel postCommentNotification({
    required String userId,
    Map<String, dynamic>? data,
    required String username,
  }) => NotificationContainerModel(
    title: "تعليق على منشورك",
    body: 'علق $username على منشورك. اطلع عليه الآن!',
    userId: userId,
    data: data,
  );

  static NotificationContainerModel commentReplyNotification({
    required String userId,
    Map<String, dynamic>? data,
    required String username,
  }) => NotificationContainerModel(
    title: "رد على تعليقك",
    body: 'قام $username بالرد على تعليقك. تحقق منه!',
    userId: userId,
    data: data,
  );

  static NotificationContainerModel postRepostNotification({
    required String userId,
    Map<String, dynamic>? data,
    required String username,
  }) => NotificationContainerModel(
    title: "إعادة نشر لمنشورك",
    body: 'قام $username بإعادة نشر منشورك!',
    userId: userId,
    data: data,
  );

  static NotificationContainerModel reviewRepostNotification({
    required String userId,
    Map<String, dynamic>? data,
    required String username,
  }) => NotificationContainerModel(
    title: "إعادة نشر لتقييمك",
    body: 'قام $username بإعادة نشر تقييمك. تحقق من التفاعل!',
    userId: userId,
    data: data,
  );
}
