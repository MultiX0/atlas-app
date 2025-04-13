import 'package:atlas_app/imports.dart';

class InteractionBar extends StatelessWidget {
  static final defaultColor = Colors.grey.shade700;
  final int likes;
  final int comments;
  final int reposts;
  final bool isLiked;
  final int shares;
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
  });

  @override
  Widget build(BuildContext context) {
    TextStyle countStyle = TextStyle(fontSize: 14, color: Colors.grey.shade600);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CustomLikeButton(
          onTap: onLike,
          isLiked: isLiked,
          likeCount: likes,
          counterStyle: countStyle,
        ),
        _InteractionButton(
          icon: LucideIcons.message_circle,
          count: comments,
          onPressed: onComment,
          tooltip: 'Comment',
          iconColor: defaultColor,
          countStyle: countStyle,
        ),
        _InteractionButton(
          icon: LucideIcons.repeat,
          count: reposts,
          onPressed: onRepost,
          tooltip: 'Repost',
          countStyle: countStyle,
          iconColor: defaultColor,
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

  const _InteractionButton({
    required this.icon,
    required this.count,
    required this.onPressed,
    required this.tooltip,
    required this.countStyle,
    this.iconColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 4),
            Text('$count', style: countStyle),
          ],
        ),
      ),
    );
  }
}
