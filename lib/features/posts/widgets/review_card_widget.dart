import 'package:atlas_app/features/posts/widgets/post_card_widget.dart';
import 'package:atlas_app/imports.dart';

// Widget for review card
class ReviewCardWidget extends ConsumerWidget {
  final dynamic review;
  final bool reviewArabic;
  final Color color;

  const ReviewCardWidget({
    super.key,
    required this.review,
    required this.reviewArabic,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardWidget(
      color: color,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: reviewArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.blackColor,
                backgroundImage: CachedNetworkAvifImageProvider(review.user!.avatar),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("@${review.user?.username}"),
                    const SizedBox(height: 5),
                    buildRatingBar(rating: review.overall, comic: null, itemSize: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            review.review,
            textDirection: reviewArabic ? TextDirection.rtl : TextDirection.ltr,
            textAlign: reviewArabic ? TextAlign.right : TextAlign.left,
            style: TextStyle(fontFamily: reviewArabic ? arabicPrimaryFont : primaryFont),
          ),
        ],
      ),
    );
  }
}
