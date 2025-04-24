// Generic Widgets
import 'package:atlas_app/core/common/widgets/cached_avatar.dart';
import 'package:atlas_app/features/comics/widgets/card_container.dart';
import 'package:atlas_app/features/comics/widgets/rating_bar_display.dart';
import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

// Abstract Interfaces
abstract class ReviewableContent {
  String get id;
  String get title;
}

abstract class ReviewModel {
  String get id;
  String get reviewText;
  String get userId;
  UserModel? get user;
  int get likesCount;
  bool get isLiked;
  double get rating;
  DateTime get createdAt;
  DateTime? get updatedAt;
  List<String> get images;
  int get reviewsCount;
}

class GenericUserReviewCard extends StatelessWidget {
  const GenericUserReviewCard({
    super.key,
    required this.review,
    required this.content,
    required this.isMe,
    required this.onLike,
  });

  final ReviewModel review;
  final ReviewableContent content;
  final bool isMe;
  final Future<bool?> Function() onLike;

  @override
  Widget build(BuildContext context) {
    final reviewArabic = Bidi.hasAnyRtl(review.reviewText);

    return CardContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: reviewArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ReviewHeader(review: review, content: content, isMe: isMe),
          const SizedBox(height: 8),
          ReviewTimeInfo(review: review),
          const SizedBox(height: 15),
          ReviewContent(review: review.reviewText, reviewArabic: reviewArabic),
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 15),
            ReviewImages(images: review.images),
            const SizedBox(height: 15),
          ],
          ReviewActions(review: review, onLike: onLike, userId: review.userId),
        ],
      ),
    );
  }
}

class ReviewHeader extends StatelessWidget {
  const ReviewHeader({super.key, required this.review, required this.content, required this.isMe});

  final ReviewModel review;
  final ReviewableContent content;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CachedAvatar(avatar: review.user!.avatar),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("@${review.user?.username ?? 'Unknown'}"),
              const SizedBox(height: 5),
              RatingBarDisplay(rating: review.rating, itemSize: 12),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},

          // () => openSheet(
          //   context: context,
          //   child: GenericReviewSheet(isCreator: isMe, review: review),
          // ),
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}

class ReviewTimeInfo extends StatelessWidget {
  const ReviewTimeInfo({super.key, required this.review});

  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Text(
      review.updatedAt == null
          ? appDateTimeFormat(review.createdAt)
          : "${appDateTimeFormat(review.createdAt)} (محدث)",
      style: const TextStyle(fontSize: 12),
    );
  }
}

class ReviewContent extends StatelessWidget {
  const ReviewContent({super.key, required this.review, required this.reviewArabic});

  final String review;
  final bool reviewArabic;

  @override
  Widget build(BuildContext context) {
    return Text(
      review,
      textDirection: reviewArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      textAlign: reviewArabic ? TextAlign.right : TextAlign.left,
      style: TextStyle(fontFamily: reviewArabic ? arabicPrimaryFont : primaryFont),
    );
  }
}

class ReviewImages extends StatelessWidget {
  const ReviewImages({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    // Replace with your actual implementation
    return Wrap(
      spacing: 10,
      children: images.map((url) => Image.network(url, width: 100)).toList(),
    );
  }
}

class ReviewActions extends StatelessWidget {
  const ReviewActions({
    super.key,
    required this.review,
    required this.userId,
    required this.onLike,
  });

  final ReviewModel review;
  final String userId;
  final Future<bool?> Function() onLike;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomLikeButton(
          likeCount: review.likesCount,
          onTap: (_) async => onLike(),
          isLiked: review.isLiked,
          size: 24,
        ),
        const SizedBox(width: 15),
        IconButton(
          onPressed: () {
            // Replace with your review post navigation
          },
          icon: const Icon(Icons.repeat, size: 22, color: Colors.grey),
        ),
        Text(review.reviewsCount.toString()),
      ],
    );
  }
}
