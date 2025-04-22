import 'package:atlas_app/imports.dart';

class NovelChapterInteractions extends StatelessWidget {
  const NovelChapterInteractions({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle countStyle = TextStyle(fontSize: 14, color: Colors.grey.shade400);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomLikeButton(
                onTap: (a) async {
                  return true;
                },
                isLiked: false,
                counterStyle: countStyle,
                likeCount: 10,
              ),
            ],
          ),
        ),
        Expanded(
          child: _InteractionButton(
            icon: LucideIcons.message_circle,
            count: 24,
            onPressed: () {},
            tooltip: 'Comment',
            countStyle: countStyle,
          ),
        ),
        Expanded(
          child: _InteractionButton(
            icon: TablerIcons.eye,
            count: 93,
            onPressed: null,
            tooltip: 'Comment',
            countStyle: countStyle,
          ),
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
  }) : iconColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          if (onPressed != null) {
            onPressed!();
          }
          return;
        },
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(formatNumber(count), style: countStyle),
          ],
        ),
      ),
    );
  }
}
