import 'package:atlas_app/core/common/utils/deletion_sheet.dart';
import 'package:atlas_app/features/novels/models/novel_review_model.dart';
import 'package:atlas_app/imports.dart';

class ReviewOptionsSheet extends ConsumerWidget {
  const ReviewOptionsSheet({super.key, required this.isCreator, required this.review});

  final bool isCreator;
  final dynamic review;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [buildTitle(), buildActionList(ref, context)],
    );
  }

  void update(WidgetRef ref, BuildContext context) {
    context.pop();
    ref.read(selectedReview.notifier).state = review;
    ReviewsEnum reviewType;
    if (review is NovelReviewModel) {
      reviewType = ReviewsEnum.novel;
    } else if (review is ComicReviewModel) {
      reviewType = ReviewsEnum.comic;
    } else {
      reviewType = ReviewsEnum.webtoon;
    }

    ref.read(navsProvider).goToAddReviewPage('t', reviewType);
  }

  void delete(WidgetRef ref, BuildContext context) {
    final controller = ref.read(reviewsControllerProvider.notifier);
    context.pop();

    openSheet(
      context: context,
      child: Builder(
        builder: (context) {
          return DeleteSheet(
            message: 'هل أنت متأكد أنك تريد حذف هذا التقييم؟',
            onDelete: () {
              if (review is ComicReviewModel) {
                controller.deleteComicReview(review, context);
              }
              if (review is NovelReviewModel) {
                controller.deleteNovelReview(review, context);
              }
            },
          );
        },
      ),
    );
  }

  Widget buildActionList(WidgetRef ref, BuildContext context) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
      color: AppColors.scaffoldBackground,
    ),
    child: Column(
      children: [
        if (isCreator) buildTile("تعديل", TablerIcons.edit, onTap: () => update(ref, context)),
        if (isCreator) buildTile("حذف", TablerIcons.trash, onTap: () => delete(ref, context)),
      ],
    ),
  );

  Widget buildTile(String text, IconData icon, {required Function() onTap}) => Directionality(
    textDirection: TextDirection.rtl,
    child: ListTile(
      onTap: onTap,
      title: Text(text),
      leading: Icon(icon, color: AppColors.mutedSilver),

      titleTextStyle: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
    ),
  );

  Widget buildTitle() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 25),
    child: Text('الخيارات', style: TextStyle(fontFamily: arabicAccentFont, fontSize: 24)),
  );
}
