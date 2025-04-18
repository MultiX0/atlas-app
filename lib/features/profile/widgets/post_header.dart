import 'package:atlas_app/core/common/widgets/cached_avatar.dart';
import 'package:atlas_app/features/posts/widgets/post_options.dart';
import 'package:atlas_app/imports.dart';
import 'package:atlas_app/router.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostHeaderWidget extends StatelessWidget {
  const PostHeaderWidget({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    final user = post.user;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          CachedAvatar(avatar: user.avatar),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text("·"),
                    const SizedBox(width: 5),
                    Text(
                      timeago.format(post.createdAt, locale: "ar"),
                      style: const TextStyle(color: AppColors.mutedSilver, fontSize: 12),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Text(
                      "@${user.username}",
                      style: const TextStyle(fontSize: 13, color: AppColors.mutedSilver),
                    ),
                    if (post.isPinned) ...[
                      Consumer(
                        builder: (context, ref, _) {
                          final router = ref.read(routerProvider);
                          bool profile = router.state.uri.toString() == Routes.user;
                          if (!profile) return const SizedBox.shrink();
                          return const Row(
                            children: [
                              SizedBox(width: 5),
                              Text("·"),
                              SizedBox(width: 5),
                              Text(
                                "مثبت",
                                style: TextStyle(
                                  color: AppColors.mutedSilver,
                                  fontSize: 12,
                                  fontFamily: arabicAccentFont,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(LucideIcons.pin, color: AppColors.mutedSilver, size: 12),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, _) {
              final me = ref.watch(userState.select((state) => state.user!));
              return IconButton(
                onPressed: () => postOptions(context, me, ref),
                icon: const Icon(TablerIcons.dots, color: AppColors.mutedSilver),
                iconSize: 18,
              );
            },
          ),
        ],
      ),
    );
  }

  void postOptions(BuildContext context, UserModel user, WidgetRef ref) {
    bool isOwner = post.userId == user.userId;
    openSheet(
      context: context,
      child: PostOptions(isOwner: isOwner, post: post),
      scrollControlled: true,
    );
  }
}
