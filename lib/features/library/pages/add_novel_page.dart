import 'dart:io';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/image_picker.dart';
import 'package:atlas_app/features/library/widgets/age_selector_sheet.dart';
import 'package:atlas_app/features/library/widgets/genres_novel.dart';
import 'package:atlas_app/features/library/widgets/novel_genres_selection.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/db/novels_db.dart';
import 'package:atlas_app/features/novels/models/novels_genre_model.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/foundation.dart';

class AddNovelPage extends ConsumerStatefulWidget {
  final bool edit;

  const AddNovelPage({super.key, required this.edit});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddNovelPageState();
}

class _AddNovelPageState extends ConsumerState<AddNovelPage> {
  late TextEditingController _nameController;
  late TextEditingController _storyController;
  List<NovelsGenreModel> genreses = [];
  List<NovelsGenreModel> selectedGenres = [];
  File? poster;
  File? banner;
  int? age;
  String? posterUrl;
  String? bannerUrl;

  @override
  void initState() {
    fetchGenreses();
    WidgetsBinding.instance.addPostFrameCallback((_) => handleState());
    _nameController = TextEditingController();
    _storyController = TextEditingController();
    super.initState();
  }

  void handleState() {
    if (!widget.edit) return;
    final novel = ref.read(selectedNovelProvider)!;

    setState(() {
      selectedGenres = novel.genrese;
      posterUrl = novel.poster;
      bannerUrl = novel.banner;
      age = novel.ageRating;
      _nameController.text = novel.title;
      _storyController.text = novel.synopsis;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  Future<void> fetchGenreses() async {
    await Future.microtask(() async {
      final list = await ref.read(novelsDbProvider).getNovelsGenreses();
      setState(() {
        genreses = list;
      });
    });
  }

  void choseImage({bool poster = false}) async {
    final _images = await imagePicker(true);
    final image = _images.first;

    setState(() {
      if (poster) {
        this.poster = image;
      } else {
        banner = image;
      }
    });
  }

  void submit() {
    final title = _nameController.text.trim();
    final story = _storyController.text.trim();
    if (title.isEmpty || story.isEmpty) {
      CustomToast.error("الرجاء تعبئة كل الحقول");
      return;
    }
    if (poster == null && !widget.edit) {
      CustomToast.error("الرجاء اضافة بوستر للرواية");
      return;
    }

    if (selectedGenres.isEmpty) {
      CustomToast.error("الرجاء اختيار تصنيف واحد على الأقل للرواية");
      return;
    }

    if (age == null) {
      CustomToast.error("الرجاء اختيار فئة عمرية");
      return;
    }

    if (story.length < 60 && !kDebugMode) {
      CustomToast.error("على الملخص على الأقل أن يحتوي على 60 حرف");
      return;
    }

    final me = ref.read(userState.select((state) => state.user!));

    if (widget.edit) {
      ref
          .read(novelsControllerProvider.notifier)
          .updateNovel(
            title: title,
            story: story,
            src_lang: 'ar',
            age_rating: age ?? 16,
            userId: me.userId,
            poster: poster,
            posterUrl: posterUrl,
            bannerUrl: bannerUrl,
            genres: selectedGenres,
            banner: banner,
            context: context,
          );
      return;
    }

    ref
        .read(novelsControllerProvider.notifier)
        .handleInsertNewNovel(
          title: title,
          story: story,
          src_lang: 'ar',
          age_rating: age ?? 16,
          userId: me.userId,
          poster: poster!,
          genres: selectedGenres,
          context: context,
          banner: banner,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("اضافة رواية جديدة"),
        actions: [IconButton(onPressed: submit, icon: const Icon(LucideIcons.check))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: GestureDetector(
              onTap: () => choseImage(),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.textFieldFillColor,
                  borderRadius: BorderRadius.circular(15),
                  image:
                      banner != null
                          ? DecorationImage(
                            image: FileImage(banner!),
                            fit: BoxFit.cover,
                            opacity: .75,
                          )
                          : bannerUrl != null
                          ? DecorationImage(
                            image: CachedNetworkImageProvider(bannerUrl!),
                            fit: BoxFit.cover,
                            opacity: .75,
                          )
                          : null,
                ),
                child: const Center(child: Icon(LucideIcons.image)),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => choseImage(poster: true),
                    child: Container(
                      width: 130,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.textFieldFillColor,
                        borderRadius: BorderRadius.circular(15),
                        image:
                            poster != null
                                ? DecorationImage(
                                  image: FileImage(poster!),
                                  fit: BoxFit.cover,
                                  opacity: .75,
                                )
                                : posterUrl != null
                                ? DecorationImage(
                                  image: CachedNetworkImageProvider(posterUrl!),
                                  fit: BoxFit.cover,
                                  opacity: .75,
                                )
                                : null,
                      ),
                      child: const Center(child: Icon(LucideIcons.image)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Column(
                    children: [
                      CustomTextFormField(
                        controller: _nameController,
                        hintText: 'الاسم',
                        maxLength: 100,
                      ),
                      const SizedBox(height: 10),
                      CustomTextFormField(
                        controller: _storyController,
                        hintText: 'ملخص أو القصة',
                        minLines: 4,
                        maxLines: 4,
                        maxLength: 1600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          buildGenreses(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "يمكنك أختيار 3 تصنيفات كحد أقصى",
              style: TextStyle(
                color: AppColors.mutedSilver.withValues(alpha: .65),
                fontFamily: arabicPrimaryFont,
                fontSize: 12,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 20),

          InkWell(
            onTap:
                () => openSheet(
                  context: context,
                  child: AgeCategorySheet(
                    onSelect: (age) {
                      setState(() {
                        this.age = age;
                      });
                    },
                  ),
                ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textFieldFillColor,
                borderRadius: BorderRadius.circular(Spacing.normalRaduis),
              ),
              child:
                  age == null
                      ? Text(
                        "الرجاء اختيار الفئة العمرية",
                        style: TextStyle(
                          color: AppColors.mutedSilver.withValues(alpha: .65),
                          fontFamily: arabicPrimaryFont,
                          fontSize: 16,
                        ),
                        textDirection: TextDirection.rtl,
                      )
                      : Text(
                        "+$age",
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "الفئة العمرية المستهدفة",
              style: TextStyle(
                color: AppColors.mutedSilver.withValues(alpha: .65),
                fontFamily: arabicPrimaryFont,
                fontSize: 12,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  InkWell buildGenreses(BuildContext context) {
    return InkWell(
      onTap:
          () => openSheet(
            context: context,
            child: GenreSelectionSheet(
              genres: genreses,
              onUpdate: (updatedGenres) {
                setState(() {
                  selectedGenres = List.from(updatedGenres);
                });
              },
              selectedGenres: selectedGenres,
            ),
          ),
      child: Genreses(selectedGenres: selectedGenres),
    );
  }
}
