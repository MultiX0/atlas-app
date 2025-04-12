import 'dart:io';

import 'package:atlas_app/core/common/utils/image_picker.dart';
import 'package:atlas_app/imports.dart';
import 'package:msh_checkbox/msh_checkbox.dart';

class AddComicReview extends ConsumerStatefulWidget {
  const AddComicReview({super.key, required this.update});

  final bool update;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddComicReviewState();
}

class _AddComicReviewState extends ConsumerState<AddComicReview> {
  late TextEditingController _controller;
  final formKey = GlobalKey<FormState>();
  double writingQuality = 1.0;
  double storyDevelopment = 1.0;
  double characterDesign = 1.0;
  double updateStability = 1.0;
  double worldBackground = 1.0;
  double overall = 1.0;
  bool spoilers = false;
  List<File> images = [];

  @override
  void initState() {
    _controller = TextEditingController();
    handleState();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleState() {
    if (widget.update) {
      final review = ref.read(selectedReview);
      if (review != null) {
        setState(() {
          writingQuality = review.writingQuality;
          storyDevelopment = review.storyDevelopment;
          characterDesign = review.characterDesign;
          updateStability = review.updateStability;
          worldBackground = review.worldBackground;
          overall = review.overall;
          _controller.text = review.review;
          spoilers = review.spoilers;
        });
      }
    }
  }

  void _calculateOverall() {
    setState(() {
      overall =
          (writingQuality +
              storyDevelopment +
              characterDesign +
              updateStability +
              worldBackground) /
          5.0;
    });
  }

  void handleImages() async {
    if (widget.update) return;
    final _images = await imagePicker(false);
    setState(() {
      images = [...images, ..._images];
    });
  }

  void handleSubmit() {
    if (formKey.currentState!.validate()) {
      final me = ref.read(userState);
      final comic = ref.read(selectedComicProvider)!;

      if (widget.update) return handleUpdate();

      ref
          .read(reviewsControllerProvider.notifier)
          .insertComicReview(
            context: context,
            comicId: comic.comicId,
            images: images,
            userId: me.user!.userId,
            writingQuality: writingQuality,
            reviewText: _controller.text.trim(),
            storyDevelopment: storyDevelopment,
            characterDesign: characterDesign,
            updateStability: updateStability,
            worldBackground: worldBackground,
            overall: overall,
            spoilers: spoilers,
          );
    }
  }

  void handleUpdate() {
    final review = ref.read(selectedReview)!;
    if (_controller.text.trim() == review.review &&
        review.characterDesign == characterDesign &&
        review.storyDevelopment == storyDevelopment &&
        review.updateStability == updateStability &&
        review.worldBackground == worldBackground &&
        review.writingQuality == writingQuality &&
        review.spoilers == spoilers) {
      context.pop();
      return;
    }

    ComicReviewModel _review = ComicReviewModel.from(reviewModel: review);
    _review = _review.copyWith(
      characterDesign: characterDesign,
      overall: overall,
      spoilers: spoilers,
      review: _controller.text.trim(),
      storyDevelopment: storyDevelopment,
      updateStability: updateStability,
      worldBackground: worldBackground,
      writingQuality: writingQuality,
      updatedAt: DateTime.now(),
    );

    ref.read(reviewsControllerProvider.notifier).updateComicReview(_review, context);
  }

  @override
  Widget build(BuildContext context) {
    final comic = ref.watch(selectedComicProvider)!;
    final overAllColor = comic.color != null ? HexColor(comic.color!) : AppColors.whiteColor;
    final checkColor = comic.color != null ? HexColor(comic.color!) : AppColors.primary;

    final me = ref.watch(userState);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.update ? "تحديث المراجعة" : "اضافة مراجعة"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: handleSubmit,
              tooltip: "نشر",
              icon: const Icon(TablerIcons.check),
              color: overAllColor,
            ),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LanguageText(
                accent: true,

                "ملحوظة: يمكنك سحب النجوم.",
                style: TextStyle(fontFamily: arabicAccentFont),
              ),
            ),
            const SizedBox(height: 10),
            buildCard(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
              child: Column(
                children: [
                  buildRating(
                    "جودة الكتابة",
                    rating: writingQuality,
                    onRatingUpdate: (rating) => setState(() => writingQuality = rating),
                  ),
                  buildRating(
                    "بناء القصة",
                    rating: storyDevelopment,
                    onRatingUpdate: (rating) => setState(() => storyDevelopment = rating),
                  ),
                  buildRating(
                    "تصميم الشخصيات",
                    rating: characterDesign,
                    onRatingUpdate: (rating) => setState(() => characterDesign = rating),
                  ),
                  buildRating(
                    "تطور الأحداث",
                    rating: updateStability,
                    onRatingUpdate: (rating) => setState(() => updateStability = rating),
                  ),
                  buildRating(
                    "بناء العالم",
                    rating: worldBackground,
                    onRatingUpdate: (rating) => setState(() => worldBackground = rating),
                  ),
                  const SizedBox(height: 10),
                  buildCard(
                    color: AppColors.blackColor,
                    padding: const EdgeInsets.all(16.0),
                    raduis: 15,
                    child: Row(
                      children: [
                        const Text(
                          "إجمالي",
                          style: TextStyle(fontFamily: arabicAccentFont, fontSize: 15),
                        ),
                        const Spacer(),
                        Text(
                          overall.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: overAllColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            buildCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.blackColor,
                        backgroundImage: CachedNetworkAvifImageProvider(me.user!.avatar),
                      ),
                      const SizedBox(width: 10),
                      Text("@${me.user?.username}"),
                    ],
                  ),

                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: TextFormField(
                      controller: _controller,
                      cursorColor: overAllColor,
                      maxLength: 280,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'يرجى ملء محتوى المراجعة';
                        }

                        if (val.length < 40) {
                          return 'يجب أن تكون المراجعة أكثر من 40 حرفًا';
                        }

                        return null;
                      },
                      maxLines: null,
                      style: const TextStyle(fontFamily: arabicAccentFont),

                      decoration: const InputDecoration(
                        errorStyle: TextStyle(fontFamily: arabicPrimaryFont, fontSize: 12),
                        hintStyle: TextStyle(fontFamily: arabicAccentFont),
                        hintText: "يجب أن تكون المراجعة أكثر من 40 حرفًا",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (!widget.update)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: overAllColor.withValues(alpha: .25),
                      foregroundColor: overAllColor,
                    ),
                    onPressed: handleImages,
                    label: const LanguageText(
                      accent: true,

                      "اضافة صور",
                      style: TextStyle(fontFamily: arabicAccentFont),
                    ),
                    icon: Icon(TablerIcons.photo, color: overAllColor),
                  ),
                const Spacer(),
                LanguageText(
                  accent: true,
                  "يحتوي على حرق",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: overAllColor,
                    fontFamily: arabicAccentFont,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 15),

                MSHCheckbox(
                  size: 25,
                  value: spoilers,
                  colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                    checkedColor: checkColor,
                  ),
                  style: MSHCheckboxStyle.stroke,
                  onChanged: (selected) {
                    setState(() {
                      spoilers = selected;
                    });
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 10),
            if (images.isNotEmpty) ...[buildImages(), const SizedBox(height: 10)],
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LanguageText(
                accent: true,
                "ملاحظة: عند نشر تقييم، سيتم نشره كمنشور في موجز الأخبار الرئيسي لمساعدة الآخرين. يمكنك حذف المنشور في أي وقت.",
                style: TextStyle(fontFamily: arabicAccentFont),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImages() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, i) {
          return Container(
            margin: EdgeInsets.only(left: i == 0 ? 0 : 10),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryAccent, width: 2.5),
              image: DecorationImage(image: FileImage(images[i]), fit: BoxFit.cover),
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  images.removeAt(i);
                });
              },
              icon: Icon(LucideIcons.circle_minus, color: AppColors.errorColor),
            ),
          );
        },
      ),
    );
  }

  Widget buildRating(
    String text, {
    required double rating,
    required Function(double) onRatingUpdate,
  }) {
    final comic = ref.watch(selectedComicProvider)!;
    final starColor = comic.color != null ? HexColor(comic.color!) : AppColors.primary;

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
          RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 18,
            itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
            itemBuilder: (context, _) => Icon(Icons.star, color: starColor),
            onRatingUpdate: (newRating) {
              onRatingUpdate(newRating);
              _calculateOverall();
            },
          ),
        ],
      ),
    );
  }
}

Container buildCard({
  double raduis = Spacing.normalRaduis + 5,
  required EdgeInsets padding,
  required Widget child,
  Color color = AppColors.primaryAccent,
}) {
  return Container(
    padding: padding,
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(raduis)),
    child: child,
  );
}
