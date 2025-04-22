import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/format_number.dart';
import 'package:atlas_app/imports.dart';

class InteractionBar extends StatelessWidget {
  static final defaultColor = Colors.grey.shade700;
  final int likes;
  final int comments;
  final int reposts;
  final bool isLiked;
  final int shares;
  final bool commentOpens;
  final bool canRepost;
  final Future<bool?> Function(bool)? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;
  final bool isShared;

  const InteractionBar({
    super.key,
    this.likes = 0,
    this.shares = 0,
    this.comments = 0,
    this.reposts = 0,
    this.onLike,
    this.onComment,
    this.onRepost,
    this.onShare,
    required this.isLiked,
    required this.isShared,
    required this.canRepost,
    required this.commentOpens,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle countStyle = TextStyle(fontSize: 14, color: Colors.grey.shade600);
    TextStyle inActiveCountStyle = TextStyle(fontSize: 14, color: Colors.grey.shade800);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CustomLikeButton(
          onTap: onLike,
          size: 20,
          isLiked: isLiked,
          likeCount: likes,
          inActiveColor: defaultColor,
          counterStyle: countStyle,
        ),
        _InteractionButton(
          icon: commentOpens ? LucideIcons.message_circle : LucideIcons.message_circle_off,
          count: comments,
          active: commentOpens,
          onPressed: onComment,
          tooltip: 'Comment',
          iconColor: commentOpens ? defaultColor : Colors.grey[800]!,
          countStyle: commentOpens ? countStyle : inActiveCountStyle,
        ),
        _InteractionButton(
          icon: LucideIcons.repeat,
          count: reposts,
          active: canRepost,
          onPressed: onRepost,
          tooltip: 'Repost',
          countStyle: canRepost ? countStyle : inActiveCountStyle,
          iconColor: canRepost ? defaultColor : Colors.grey[800]!,
        ),

        _InteractionButton(
          count: shares,
          countStyle: countStyle,
          onPressed: onShare,
          tooltip: "Share",
          iconColor: isShared ? AppColors.primary.withValues(alpha: .5) : defaultColor,
          icon: TablerIcons.share_2,
        ),
      ],
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onPressed;
  final String tooltip;
  final TextStyle countStyle;
  final Color iconColor;
  final bool active;

  const _InteractionButton({
    required this.icon,
    required this.count,
    required this.onPressed,
    required this.tooltip,
    required this.countStyle,
    this.active = true,
    this.iconColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          if (!active) {
            CustomToast.error("هذه الخاصية غير فعالة على هذا المنشور");
            return;
          }

          if (onPressed != null) {
            onPressed!();
          }
          return;
        },
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 4),
            Text(formatNumber(count), style: countStyle),
          ],
        ),
      ),
    );
  }
}
