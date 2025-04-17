import 'dart:async';

import 'package:atlas_app/features/comics/widgets/review_content.dart';
import 'package:atlas_app/features/comics/widgets/review_header.dart';
import 'package:atlas_app/features/comics/widgets/review_images.dart';
import 'package:atlas_app/features/comics/widgets/reviews_actions.dart';
import 'package:atlas_app/features/comics/widgets/reviews_card_container.dart';
import 'package:atlas_app/features/comics/widgets/reviews_time_info.dart';
import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';

class UserReviewCard extends ConsumerStatefulWidget {
  UserReviewCard({super.key, required this.review, required this.index, required this.comic})
    : reviewArabic = Bidi.hasAnyRtl(review.review);

  final ComicReviewModel review;
  final int index;
  final ComicModel comic;
  final bool reviewArabic;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserReviewCardState();
}

class _UserReviewCardState extends ConsumerState<UserReviewCard> {
  Timer? _debounce;
  Future<bool?> handleLike({
    required WidgetRef ref,
    required int index,
    required ComicReviewModel review,
    required String userId,
  }) async {
    if (_debounce?.isActive ?? false) return false;
    _debounce = Timer(const Duration(milliseconds: 300), () {});
    ref
        .read(reviewsControllerProvider.notifier)
        .handleComicReviewLike(review.copyWith(i_liked: !review.i_liked), userId, index);
    return true;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(userState).user!;
    bool isMe = widget.review.userId == me.userId;
    final reviewArabic = widget.reviewArabic;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: CardContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: reviewArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ReviewHeader(review: widget.review, comic: widget.comic, isMe: isMe),
              const SizedBox(height: 8),
              ReviewTimeInfo(review: widget.review),
              const SizedBox(height: 15),
              ReviewContent(review: widget.review, reviewArabic: reviewArabic),
              if (widget.review.images.isNotEmpty) ...[
                const SizedBox(height: 15),
                GestureDetector(
                  onDoubleTap:
                      () => handleLike(
                        ref: ref,
                        index: widget.index,
                        userId: me.userId,
                        review: widget.review,
                      ),
                  child: ReviewImages(review: widget.review),
                ),
                const SizedBox(height: 15),
              ],
              ReviewActions(
                review: widget.review,
                userId: me.userId,
                onLike:
                    (_) => handleLike(
                      ref: ref,
                      index: widget.index,
                      userId: me.userId,
                      review: widget.review,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
