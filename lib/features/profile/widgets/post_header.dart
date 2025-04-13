import 'package:atlas_app/core/common/widgets/cached_avatar.dart';
import 'package:atlas_app/features/posts/models/post_model.dart';
import 'package:atlas_app/imports.dart';
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

                Text(
                  "@${user.username}",
                  style: const TextStyle(fontSize: 13, color: AppColors.mutedSilver),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(TablerIcons.dots, color: AppColors.mutedSilver),
            iconSize: 18,
          ),
        ],
      ),
    );
  }
}
