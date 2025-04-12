import 'package:atlas_app/imports.dart';
import 'package:like_button/like_button.dart';

class CustomLikeButton extends ConsumerWidget {
  const CustomLikeButton({
    super.key,
    this.size = 19,
    required this.onTap,
    required this.isLiked,
    this.likedIcon = Icons.favorite,
    required this.likeCount,
    this.unLikedIcon = Icons.favorite_border,
    this.counterStyle,
  });

  final double size;
  final Future<bool?> Function(bool)? onTap;
  // final Color color;
  final int likeCount;
  final bool isLiked;
  final IconData likedIcon;
  final IconData unLikedIcon;
  final TextStyle? counterStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LikeButton(
      countDecoration: (count, likeCount) {
        return Text((likeCount ?? 0).toString(), style: counterStyle);
      },
      isLiked: isLiked,
      size: size,

      likeCount: likeCount,
      likeCountPadding: const EdgeInsets.symmetric(horizontal: 6),
      likeCountAnimationType: LikeCountAnimationType.all,
      onTap: onTap,
      likeBuilder: (bool isLiked) {
        return Icon(
          isLiked ? likedIcon : unLikedIcon,
          color: isLiked ? Colors.pinkAccent : Colors.grey.shade800,
          size: size,
        );
      },
    );
  }
}
