import 'package:atlas_app/core/common/widgets/like_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewActions extends ConsumerWidget {
  const ReviewActions({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.reviewsCount,
    required this.userId,
    required this.onLike,
    this.onRepost,
    this.iconSize = 22,
    this.buttonSize = 24,
    this.spacing = 15,
  });

  final bool isLiked;
  final int likeCount;
  final int reviewsCount;
  final String userId;
  final Future<bool?> Function(bool) onLike;
  final VoidCallback? onRepost;
  final double iconSize;
  final double buttonSize;
  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        CustomLikeButton(
          likeCount: likeCount,
          onTap: (_) async => onLike(true),
          isLiked: isLiked,
          size: buttonSize,
        ),
        SizedBox(width: spacing),
        IconButton(
          onPressed: onRepost,
          icon: Icon(Icons.repeat, size: iconSize, color: Colors.grey),
        ),
        Text(reviewsCount.toString()),
      ],
    );
  }
}
