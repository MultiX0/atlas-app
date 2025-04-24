import 'package:atlas_app/features/comics/widgets/rating_bar_display.dart';
import 'package:atlas_app/features/novels/models/novel_review_model.dart';
import 'package:atlas_app/imports.dart';

import 'package:atlas_app/core/common/widgets/cached_avatar.dart';

import 'dart:ui' as ui;

class ReviewMentionedWidget extends StatelessWidget {
  const ReviewMentionedWidget({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    dynamic review = post.comicReviewMentioned ?? post.novelReviewMentioned;
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          if (review is NovelReviewModel) {
            context.push("${Routes.novelPage}/${review.novelId}");
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: "ردا على تقييم  ",
                        style: const TextStyle(
                          color: AppColors.mutedSilver,
                          fontFamily: arabicAccentFont,
                        ),
                        children: [
                          TextSpan(
                            text: review.user!.username,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontFamily: accentFont,
                            ),
                          ),
                          const TextSpan(
                            text: "   لــ   ",
                            style: TextStyle(color: AppColors.mutedSilver, fontFamily: accentFont),
                          ),
                          TextSpan(
                            text:
                                review is NovelReviewModel
                                    ? review.novelTitle
                                    : review!.comic_title,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontFamily: accentFont,
                            ),
                          ),
                        ],
                      ),
                      textDirection: ui.TextDirection.rtl,
                    ),
                    RatingBarDisplay(rating: review!.overall, itemSize: 12),
                    Text(
                      review!.review,
                      style: const TextStyle(color: AppColors.mutedSilver, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textDirection: ui.TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              CachedAvatar(avatar: review!.user!.avatar, raduis: 15),
            ],
          ),
        ),
      ),
    );
  }
}
