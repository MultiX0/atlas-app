import 'dart:io';

import 'package:atlas_app/core/common/utils/image_picker.dart';
import 'package:atlas_app/features/auth/providers/user_state.dart';
import 'package:atlas_app/features/comics/providers/providers.dart';
import 'package:atlas_app/features/reviews/controller/reviews_controller.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:msh_checkbox/msh_checkbox.dart';

class AddComicReview extends ConsumerStatefulWidget {
  const AddComicReview({super.key});

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
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    final _images = await imagePicker(false);
    setState(() {
      images = _images;
    });
  }

  void handleSubmit() {
    if (formKey.currentState!.validate()) {
      final me = ref.read(userState);
      final comic = ref.read(selectedComicProvider)!;

      ref
          .read(reviewsControllerProvider.notifier)
          .insertComicReview(
            comicId: comic.comicId,
            images: images,
            userId: me!.user!.userId,
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

  @override
  Widget build(BuildContext context) {
    final comic = ref.watch(selectedComicProvider)!;
    final overAllColor = comic.color != null ? HexColor(comic.color!) : AppColors.whiteColor;
    final checkColor = comic.color != null ? HexColor(comic.color!) : AppColors.primary;

    final me = ref.watch(userState);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a Review"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: handleSubmit,
              tooltip: "Post",
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
              child: Text("Note: You can drag the stars."),
            ),
            const SizedBox(height: 10),
            buildCard(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
              child: Column(
                children: [
                  buildRating(
                    "Writing Quality",
                    rating: writingQuality,
                    onRatingUpdate: (rating) => setState(() => writingQuality = rating),
                  ),
                  buildRating(
                    "Story Development",
                    rating: storyDevelopment,
                    onRatingUpdate: (rating) => setState(() => storyDevelopment = rating),
                  ),
                  buildRating(
                    "Character Design",
                    rating: characterDesign,
                    onRatingUpdate: (rating) => setState(() => characterDesign = rating),
                  ),
                  buildRating(
                    "Update Stability",
                    rating: updateStability,
                    onRatingUpdate: (rating) => setState(() => updateStability = rating),
                  ),
                  buildRating(
                    "World Background",
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
                        const Text("Overall"),
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
                        backgroundImage: CachedNetworkAvifImageProvider(me!.user!.avatar),
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
                          return 'please fill the review content';
                        }

                        if (val.length < 40) {
                          return 'Review should be more than 40 characters';
                        }

                        return null;
                      },
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "Review should be more than 40 characters",
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
                // IconButton(
                // onPressed: () => CustomToast.soon(),
                // icon: Icon(TablerIcons.photo, color: overAllColor),
                // ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: overAllColor.withValues(alpha: .25),
                    foregroundColor: overAllColor,
                  ),
                  onPressed: handleImages,
                  label: const Text("Upload Images"),
                  icon: Icon(TablerIcons.photo, color: overAllColor),
                ),
                const Spacer(),
                Text(
                  "Spoilers",
                  style: TextStyle(fontWeight: FontWeight.bold, color: overAllColor),
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
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Note: When you post a review, it will also be shared as a post in the main feed to help others. You can delete the post anytime if you choose to.",
              ),
            ),
          ],
        ),
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
              fontFamily: accentFont,
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
