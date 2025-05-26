import 'package:atlas_app/imports.dart';
import 'package:atlas_app/core/common/widgets/cached_avatar.dart';
import 'package:atlas_app/features/comics/widgets/rating_bar_display.dart';

class ReviewHeader extends ConsumerWidget {
  const ReviewHeader({
    super.key,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.rating,
    required this.color,
    required this.isMe,
    required this.isAdmin,
    this.itemSize = 12,
    this.iconSize = 20,
    this.onMenuPressed,
  });

  final String userId;
  final String username;
  final String avatarUrl;
  final double rating;
  final Color color;
  final bool isMe;
  final bool isAdmin;
  final double itemSize;
  final double iconSize;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: Row(
        children: [
          CachedAvatar(avatar: avatarUrl),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("@$username"),
                    if (isAdmin) ...[const SizedBox(width: 5)],
                    Visibility(
                      visible: isAdmin,
                      child: const Icon(
                        LucideIcons.badge_check,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                RatingBarDisplay(rating: rating, color: color, itemSize: itemSize),
              ],
            ),
          ),
          const Spacer(),
          IconButton(onPressed: onMenuPressed, icon: Icon(Icons.more_vert, size: iconSize)),
        ],
      ),
    );
  }
}
