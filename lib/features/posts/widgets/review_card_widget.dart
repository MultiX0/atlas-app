import 'package:atlas_app/imports.dart';
import 'package:atlas_app/features/comics/widgets/rating_bar_display.dart';
import 'package:atlas_app/features/posts/widgets/post_card_widget.dart';

class ReviewCardWidget extends ConsumerWidget {
  const ReviewCardWidget({
    super.key,
    required this.reviewText,
    required this.username,
    required this.avatarUrl,
    required this.rating,
    required this.isArabic,
    required this.color,
    this.padding = const EdgeInsets.all(16),
    this.itemSize = 12,
  });

  final String reviewText;
  final String username;
  final String avatarUrl;
  final double rating;
  final bool isArabic;
  final Color color;
  final EdgeInsets padding;
  final double itemSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardWidget(
      color: color,
      padding: padding,
      child: Column(
        crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: CachedNetworkAvifImageProvider(avatarUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("@$username"),
                    const SizedBox(height: 5),
                    RatingBarDisplay(rating: rating, color: color, itemSize: itemSize),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            reviewText,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyle(fontFamily: isArabic ? 'arabicPrimaryFont' : 'primaryFont'),
          ),
        ],
      ),
    );
  }
}
