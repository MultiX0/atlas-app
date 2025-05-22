import 'package:atlas_app/core/common/enum/notificaion_type.dart';
import 'package:atlas_app/core/common/widgets/cached_avatar.dart';
import 'package:atlas_app/core/common/widgets/error_widget.dart';
import 'package:atlas_app/features/notifications/controller/notifications_controller.dart';
import 'package:atlas_app/features/notifications/db/notifications_db.dart';
import 'package:atlas_app/features/notifications/models/notification_event_model.dart';
import 'package:atlas_app/features/novels/widgets/empty_chapters.dart';
import 'package:atlas_app/imports.dart';
import 'package:grouped_list/grouped_list.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<String> readedIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الاشعارات")),
      body: Consumer(
        builder: (context, ref, _) {
          final user = ref.read(userState.select((s) => s.user!));
          return ref
              .watch(getUserNotificationsProvider(user.userId))
              .when(
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return const EmptyChapters(text: 'لايوجد لديك أي اشعارات');
                  }

                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: GroupedListView<NotificationEventRequest, DateTime>(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      cacheExtent: MediaQuery.sizeOf(context).height / 2,
                      addRepaintBoundaries: true,
                      addSemanticIndexes: true,
                      elements: notifications, // Don't map to widgets!
                      groupBy: (element) => element.createdAt!,
                      groupSeparatorBuilder:
                          (DateTime date) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 25),
                            child: Text(
                              appDateFormat(date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: arabicAccentFont,
                              ),
                            ),
                          ),
                      itemBuilder:
                          (context, notification) => RepaintBoundary(
                            child: ListTile(
                              key: ValueKey(notification.id),
                              onTap: () => onTap(notification, context: context),
                              leading: CachedAvatar(avatar: notification.user?.avatar ?? ""),
                              title: Text(notification.user?.fullName ?? "unknown"),
                              subtitle: Row(
                                children: [
                                  Expanded(child: Text(getNotificationText(notification))),
                                  if (!notification.isRead &&
                                      !readedIds.contains(notification.id)) ...[
                                    const SizedBox(width: 15),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                      useStickyGroupSeparators: true,
                      floatingHeader: true,
                      order: GroupedListOrder.DESC,
                    ),
                  );
                },
                error: (error, _) => AtlasErrorPage(message: error.toString()),
                loading: () => const Loader(),
              );
        },
      ),
    );
  }

  String getNotificationText(NotificationEventRequest notification) {
    final username = notification.user?.username ?? 'شخص ما';

    switch (NotificationType.fromString(notification.type)!) {
      case NotificationType.follow:
        return '$username قام بمتابعتك.';

      case NotificationType.postLike:
        return '$username أعجب بمنشورك.';

      case NotificationType.postComment:
        return '$username علّق على منشورك.';

      case NotificationType.postCommentReply:
        return '$username ردّ على تعليقك.';

      case NotificationType.newNovelReview:
        return '$username كتب مراجعة على روايتك.';

      case NotificationType.novelFavorite:
        return '$username أضاف روايتك إلى المفضلة.';

      case NotificationType.comicReviewLike:
        return '$username أعجب بمراجعتك للمانجا.';

      case NotificationType.comicReviewReply:
        return '$username ردّ على مراجعتك للمانجا.';

      case NotificationType.commentLike:
        return '$username أعجب بتعليقك.';

      case NotificationType.novelChapterLike:
        return '$username أعجب بأحد فصول روايتك.';

      case NotificationType.novelChapterComment:
        return '$username علّق على فصل من روايتك.';

      case NotificationType.novelChapterCommentLike:
        return '$username أعجب بتعليقك على الفصل.';

      case NotificationType.novelChapterCommentReply:
        return '$username ردّ على تعليقك في أحد فصول الرواية.';

      case NotificationType.novelChapterReplyLike:
        return '$username أعجب بردّك على تعليق فصل.';

      case NotificationType.novelReviewLike:
        return '$username أعجب بمراجعتك للرواية.';

      case NotificationType.postRepost:
        return '$username أعاد نشر منشورك.';

      case NotificationType.postMention:
        return '$username أشار إليك في منشور.';

      default:
        return '$username تفاعل مع محتواك.';
    }
  }

  void onTap(NotificationEventRequest notification, {required BuildContext context}) async {
    if (!notification.isRead) {
      setState(() {
        readedIds.add(notification.id!);
      });
      NotificationsDb notificationsDb = NotificationsDb();
      await notificationsDb.markNotificationAsRead(notification.id!);
    }
    Map<NotificationType, Function()> actions = {
      NotificationType.postLike: () => context.push("${Routes.postPage}/${notification.postId}"),
      NotificationType.postComment: () => context.push("${Routes.postPage}/${notification.postId}"),
      NotificationType.postCommentReply:
          () => context.push("${Routes.postPage}/${notification.postId}"),
      NotificationType.postMention: () => context.push("${Routes.postPage}/${notification.postId}"),
      NotificationType.postRepost: () => context.push("${Routes.postPage}/${notification.postId}"),
      NotificationType.novelFavorite:
          () => context.push("${Routes.novelPage}/${notification.novelId}"),
      NotificationType.novelChapterComment: () {
        context.push("${Routes.novelPage}/${notification.novelId}");
        context.push("${Routes.novelReadChapter}/${notification.chapterId}");
      },
      NotificationType.novelChapterCommentLike: () {
        context.push("${Routes.novelPage}/${notification.novelId}");
        context.push("${Routes.novelReadChapter}/${notification.chapterId}");
      },
      NotificationType.novelChapterCommentReply: () {
        context.push("${Routes.novelPage}/${notification.novelId}");
        context.push("${Routes.novelReadChapter}/${notification.chapterId}");
      },
      NotificationType.novelChapterLike: () {
        context.push("${Routes.novelPage}/${notification.novelId}");
        context.push("${Routes.novelReadChapter}/${notification.chapterId}");
      },
      NotificationType.novelChapterReplyLike: () {
        context.push("${Routes.novelPage}/${notification.novelId}");
        context.push("${Routes.novelReadChapter}/${notification.chapterId}");
      },
      NotificationType.novelCommentMention: () {
        context.push("${Routes.novelPage}/${notification.novelId}");
        context.push("${Routes.novelReadChapter}/${notification.chapterId}");
      },
      NotificationType.novelReplyMention: () {
        context.push("${Routes.novelPage}/${notification.novelId}");
        context.push("${Routes.novelReadChapter}/${notification.chapterId}");
      },
      NotificationType.novelReviewLike:
          () => context.push("${Routes.novelPage}/${notification.novelId}"),
      NotificationType.novelReviewReply:
          () => context.push("${Routes.postPage}/${notification.postId}"),
      NotificationType.comicReviewLike:
          () => context.push("${Routes.comicPage}/${notification.comic_id}"),
      NotificationType.comicReviewReply:
          () => context.push("${Routes.postPage}/${notification.postId}"),
    };

    if (actions[NotificationType.fromString(notification.type)] != null) {
      actions[NotificationType.fromString(notification.type)]!();
    }
  }
}
