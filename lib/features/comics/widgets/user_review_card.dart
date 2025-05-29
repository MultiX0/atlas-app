import 'dart:async';
import 'package:atlas_app/imports.dart';
import 'package:atlas_app/features/comics/widgets/review_content.dart';
import 'package:atlas_app/features/comics/widgets/review_header.dart';
import 'package:atlas_app/features/comics/widgets/review_images.dart';
import 'package:atlas_app/features/comics/widgets/reviews_actions.dart';
import 'package:atlas_app/features/comics/widgets/reviews_card_container.dart';
import 'package:atlas_app/features/comics/widgets/reviews_time_info.dart';
import 'package:intl/intl.dart';

class UserReviewCard extends ConsumerStatefulWidget {
  const UserReviewCard({
    super.key,
    required this.reviewText,
    required this.images,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.rating,
    required this.isLiked,
    required this.index,
    required this.color,
    required this.createdAt,
    required this.likeCount,
    required this.reviewsCount,
    required this.onLike,
    required this.spoilers,
    required this.isAdmin,
    required this.official,
    this.updatedAt,
    this.onRepost,
    this.onMenuPressed,
    this.isArabic,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    this.cardPadding = const EdgeInsets.all(16),
  });

  final String reviewText;
  final List<String> images;
  final String userId;
  final String username;
  final String avatarUrl;
  final double rating;
  final bool isLiked;
  final int index;
  final Color color;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likeCount;
  final int reviewsCount;
  final Future<bool?> Function(String userId, int index, bool isLiked) onLike;
  final VoidCallback? onRepost;
  final VoidCallback? onMenuPressed;
  final bool? isArabic;
  final EdgeInsets padding;
  final EdgeInsets cardPadding;
  final bool spoilers;
  final bool isAdmin;
  final bool official;

  @override
  ConsumerState<UserReviewCard> createState() => _UserReviewCardState();
}

class _UserReviewCardState extends ConsumerState<UserReviewCard> {
  Timer? _debounce;
  late bool see;

  @override
  void initState() {
    see = !widget.spoilers;
    super.initState();
  }

  void toggleSpoilers() {
    setState(() {
      see = true;
    });
  }

  Future<bool?> handleLike({
    required WidgetRef ref,
    required int index,
    required String userId,
    required bool isLiked,
  }) async {
    if (_debounce?.isActive ?? false) return false;
    _debounce = Timer(const Duration(milliseconds: 300), () {});
    return widget.onLike(userId, index, isLiked);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(userState.select((s) => s.user!)).userId;
    final isMe = widget.userId == currentUserId;
    final isArabic = widget.isArabic ?? Bidi.hasAnyRtl(widget.reviewText);

    var column = Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ReviewHeader(
          userId: widget.userId,
          username: widget.username,
          avatarUrl: widget.avatarUrl,
          rating: widget.rating,
          color: widget.color,
          isMe: isMe,
          isAdmin: widget.isAdmin,
          onMenuPressed: widget.onMenuPressed,
          official: widget.official,
        ),
        const SizedBox(height: 8),
        ReviewTimeInfo(createdAt: widget.createdAt, updatedAt: widget.updatedAt),
        const SizedBox(height: 15),
        ReviewContent(reviewText: widget.reviewText, isArabic: isArabic),
        if (widget.images.isNotEmpty) ...[
          const SizedBox(height: 15),
          GestureDetector(
            onDoubleTap:
                () => handleLike(
                  ref: ref,
                  index: widget.index,
                  userId: currentUserId,
                  isLiked: widget.isLiked,
                ),
            child: ReviewImages(imageUrls: widget.images),
          ),
          const SizedBox(height: 15),
        ],
        ReviewActions(
          userId: widget.userId,
          isLiked: widget.isLiked,
          likeCount: widget.likeCount,
          reviewsCount: widget.reviewsCount,
          onLike:
              (_) => handleLike(
                ref: ref,
                index: widget.index,
                userId: currentUserId,
                isLiked: widget.isLiked,
              ),
          onRepost: widget.onRepost,
        ),
      ],
    );
    return RepaintBoundary(
      child: Padding(
        padding: widget.padding,
        child: CardContainer(
          padding: widget.cardPadding,
          child: see ? column : SpoilersCard(callback: toggleSpoilers),
        ),
      ),
    );
  }
}

class SpoilersCard extends StatelessWidget {
  const SpoilersCard({super.key, required this.callback});

  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/spoilers.png', height: size.width * .25),
          const SizedBox(height: 15),
          const Text("يحتوي على حرق", style: TextStyle(fontFamily: arabicAccentFont, fontSize: 16)),
          const SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondBlackColor,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.normalRaduis),
              ),
              foregroundColor: AppColors.primary,
            ),
            onPressed: callback,
            child: const Text("مشاهدة", style: TextStyle(fontFamily: arabicAccentFont)),
          ),
        ],
      ),
    );
  }
}
