import 'dart:developer';
import 'dart:io';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/image_picker.dart';
import 'package:atlas_app/features/library/widgets/age_selector_sheet.dart';
import 'package:atlas_app/features/library/widgets/genres_novel.dart';
import 'package:atlas_app/features/library/widgets/novel_genres_selection.dart';
import 'package:atlas_app/features/novels/db/novels_db.dart';
import 'package:atlas_app/features/novels/models/novels_genre_model.dart';
import 'package:atlas_app/imports.dart';

class AddNovelPage extends ConsumerStatefulWidget {
  const AddNovelPage({super.key});

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

  @override
  void initState() {
    fetchGenreses();
    _nameController = TextEditingController();
    _storyController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  Future<void> fetchGenreses() async {
    await Future.microtask(() async {
      final list = await ref.read(novelDbProvider).getNovelsGenreses();
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
    if (poster == null) {
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
    context.pop();
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
                      banner == null
                          ? null
                          : DecorationImage(
                            image: FileImage(banner!),
                            fit: BoxFit.cover,
                            opacity: .75,
                          ),
                ),
                child: const Center(child: Icon(LucideIcons.image)),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
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
                          poster == null
                              ? null
                              : DecorationImage(
                                image: FileImage(poster!),
                                fit: BoxFit.cover,
                                opacity: .75,
                              ),
                    ),
                    child: const Center(child: Icon(LucideIcons.image)),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Flexible(
                child: Column(
                  children: [
                    CustomTextFormField(hintText: 'الاسم', maxLength: 100),
                    SizedBox(height: 10),
                    CustomTextFormField(
                      hintText: 'ملخص أو القصة',
                      minLines: 4,
                      maxLines: 4,
                      maxLength: 300,
                    ),
                  ],
                ),
              ),
            ],
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
              onSelect: (gen) {
                log(gen.name);

                setState(() {
                  if (selectedGenres.any((g) => g.name == gen.name)) {
                    selectedGenres.remove(gen);
                  } else {
                    if (selectedGenres.length >= 3) {
                      CustomToast.error("يمكنك أختيار 3 كأقصى حد");
                      return;
                    }
                    selectedGenres.add(gen);
                  }
                });
              },
              selectedGenreses: selectedGenres,
            ),
          ),
      child: Genreses(selectedGenres: selectedGenres),
    );
  }
}
