import 'package:atlas_app/core/common/widgets/cached_avatar.dart';
import 'package:atlas_app/features/comics/widgets/rating_bar_display.dart';
import 'package:atlas_app/imports.dart';

class ReviewHeader extends ConsumerWidget {
  const ReviewHeader({super.key, required this.review, required this.comic, required this.isMe});

  final ComicReviewModel review;
  final ComicModel comic;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: Row(
        children: [
          CachedAvatar(avatar: review.user!.avatar),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("@${review.user?.username}"),
                const SizedBox(height: 5),
                RatingBarDisplay(rating: review.overall, comic: comic, itemSize: 12),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed:
                () => openSheet(
                  context: context,
                  child: ComicReviewSheet(isCreator: isMe, review: review),
                ),
            icon: const Icon(TablerIcons.dots_vertical, size: 20),
          ),
        ],
      ),
    );
  }
}
