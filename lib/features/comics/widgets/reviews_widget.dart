import 'package:atlas_app/core/common/enum/post_type.dart';
import 'package:atlas_app/core/common/utils/gallery_image_view.dart';
import 'package:atlas_app/core/common/utils/sheet.dart';
import 'package:atlas_app/core/common/widgets/loader.dart';
import 'package:atlas_app/core/services/gal_service.dart';
import 'package:atlas_app/features/auth/providers/user_state.dart';
import 'package:atlas_app/features/comics/models/comic_model.dart';
import 'package:atlas_app/features/comics/providers/manhwa_reviews_state.dart';
import 'package:atlas_app/features/navs/navs.dart';
import 'package:atlas_app/features/reviews/models/avg_reviews_model.dart';
import 'package:atlas_app/features/reviews/models/comic_review_model.dart';
import 'package:atlas_app/features/reviews/widgets/comic_review_sheet.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class ReviewsWidget extends ConsumerStatefulWidget {
  const ReviewsWidget({
    super.key,
    required this.reviews,
    required this.comic,
    required this.scrollController,
    required this.iAlreadyReviewdOnce,
  });
  final List<ComicReviewModel> reviews;
  final ComicModel comic;
  final ScrollController scrollController;
  final bool iAlreadyReviewdOnce;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends ConsumerState<ReviewsWidget> {
  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(manhwaReviewsStateProvider(widget.comic.comicId));
    final avg = reviewsState.avgReviews;
    return SliverList.builder(
      itemCount: widget.reviews.length + (reviewsState.moreLoading ? 2 : 1),
      itemBuilder: (cntext, i) {
        if (i == 0) {
          return GestureDetector(onTap: onTap, child: buildAvgCard(avg));
        }
        if (i == (widget.reviews.length + 1)) {
          return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Loader()));
        }
        final review = widget.reviews.elementAt(i - 1);
        return buildUserReviewCard(review);
      },
    );
  }

  Widget buildUserReviewCard(ComicReviewModel review) {
    final me = ref.watch(userState).user!;
    bool isMe = review.userId == me.userId;
    final reviewArabic = Bidi.hasAnyRtl(review.review);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: buildCard(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("@${review.user?.username}"),
                    const SizedBox(height: 5),
                    buildRatingBar(rating: review.overall, comic: widget.comic, itemSize: 12),
                  ],
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

            const SizedBox(height: 15),
            Text(
              review.review,
              textDirection: reviewArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              textAlign: reviewArabic ? TextAlign.right : TextAlign.left,
              style: TextStyle(fontFamily: reviewArabic ? arabicPrimaryFont : primaryFont),
            ),
            if (review.images.isNotEmpty) ...[const SizedBox(height: 15), buildImage(review)],
          ],
        ),
      ),
    );
  }

  void onTap() {
    if (widget.reviews.isEmpty || !widget.iAlreadyReviewdOnce) {
      ref.read(navsProvider).goToAddComicReviewPage('f');
    } else {
      ref.read(navsProvider).goToMakePostPage(PostType.comic);
    }
  }

  Widget buildImage(ComicReviewModel review) {
    final List<ImageProvider> _imageProviders =
        review.images.map((image) => CachedNetworkAvifImageProvider(image)).toList();
    return GalleryImageView(
      listImage: _imageProviders,
      width: double.infinity,
      height: 200,
      boxFit: BoxFit.cover,
      imageDecoration: BoxDecoration(
        border: Border.all(color: AppColors.secondBlackColor),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget buildAvgCard(AvgReviewsModel avg) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
      child: buildCard(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: LanguageText(
                accent: true,
                "متوسط التقييمات",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: arabicAccentFont,
                ),
              ),
            ),
            const SizedBox(height: 15),
            if (widget.reviews.isNotEmpty) ...[
              buildAvgRatings(avg: avg, comic: widget.comic),
            ] else ...[
              buildEmptyRatings(),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildEmptyRatings() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.scaffoldBackground,
        border: Border.all(color: AppColors.blackColor, width: 3),
      ),
      child: const LanguageText(
        "لاتوجد أي تقييمات حاليا لهذا العمل, كن أول من يقيمه!",
        style: TextStyle(color: AppColors.mutedSilver),
      ),
    );
  }
}

Widget buildAvgRatings({required AvgReviewsModel avg, required ComicModel comic}) {
  final overAllColor = comic.color != null ? HexColor(comic.color!) : AppColors.whiteColor;

  return Column(
    children: [
      buildRating("جودة الكتابة", rating: avg.writing_quality_avg, comic: comic),
      buildRating("بناء القصة", rating: avg.story_development_avg, comic: comic),
      buildRating("تصميم الشخصيات", rating: avg.character_design_avg, comic: comic),
      buildRating("تطور الأحداث", rating: avg.update_stability_avg, comic: comic),
      buildRating("بناء العالم", rating: avg.world_background_avg, comic: comic),
      const SizedBox(height: 10),
      buildCard(
        color: AppColors.blackColor,
        padding: const EdgeInsets.all(16.0),
        raduis: 15,
        child: Row(
          children: [
            const Text("إجمالي", style: TextStyle(fontFamily: arabicAccentFont, fontSize: 15)),
            const Spacer(),
            Text(
              avg.overall_avg.toStringAsFixed(1),
              style: TextStyle(fontWeight: FontWeight.bold, color: overAllColor, fontSize: 16),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget buildRating(String text, {required double rating, required ComicModel comic}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontFamily: arabicAccentFont,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        buildRatingBar(comic: comic, rating: rating),
      ],
    ),
  );
}

Widget buildRatingBar({required double rating, required ComicModel comic, double itemSize = 18}) {
  final starColor = comic.color != null ? HexColor(comic.color!) : AppColors.primary;
  return RatingBarIndicator(
    direction: Axis.horizontal,
    itemCount: 5,
    rating: rating,
    itemSize: itemSize,
    itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
    itemBuilder: (context, _) => Icon(Icons.star, color: starColor),
  );
}

Container buildCard({
  double raduis = Spacing.normalRaduis + 5,
  required EdgeInsets padding,
  required Widget child,
  Color color = AppColors.primaryAccent,
}) {
  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
    ),
    child: child,
  );
}
