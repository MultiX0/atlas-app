import 'dart:io';
import 'package:atlas_app/core/common/utils/image_picker.dart';
import 'package:atlas_app/features/posts/controller/posts_controller.dart';
import 'package:atlas_app/features/posts/providers/providers.dart';
import 'package:atlas_app/features/posts/widgets/comic_review_tree_widget.dart';
import 'package:atlas_app/features/posts/widgets/post_field_widget.dart';
import 'package:atlas_app/features/posts/widgets/tools_widget.dart';
import 'package:atlas_app/imports.dart';

// Main page widget
class MakePostPage extends ConsumerStatefulWidget {
  const MakePostPage({super.key, required this.postType, this.defaultText});

  final String? defaultText;
  final PostType postType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MakePostPageState();
}

class _MakePostPageState extends ConsumerState<MakePostPage> {
  late TextEditingController _controller;
  List<Map<String, dynamic>> mentionSuggestions = [];
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

  void handleImages() async {
    final _images = await imagePicker(false);
    setState(() {
      images = [...images, ..._images];
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputVal = ref.watch(postInputProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("انشاء منشور"),
        centerTitle: true,
        actions: [
          Visibility(
            maintainState: true,
            maintainSize: false,
            maintainAnimation: true,
            visible: inputVal.trim().isNotEmpty,
            child: AnimatedScale(
              scale: inputVal.trim().isNotEmpty ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: IconButton(
                onPressed: () {
                  if (inputVal.trim().isEmpty) {
                    return;
                  }
                  final data = ref.read(postInputProvider);
                  ref
                      .read(postsControllerProvider.notifier)
                      .insertPost(
                        postType: widget.postType,
                        postContent: data,
                        context: context,
                        images: images,
                      );
                },
                icon: const Icon(LucideIcons.check),
              ),
            ),
          ),
        ],
      ),
      body: RepaintBoundary(
        child: Column(
          children: [
            const Text(
              "لحتى تمنشن شخصية أو رواية أو مانهوا اكتب / بعدها الاسم",
              style: TextStyle(color: AppColors.primary, fontFamily: arabicAccentFont),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: TypeControllerWidget(defaultText: widget.defaultText),
              ),
            ),
            if (images.isNotEmpty) ...[buildImages(), const SizedBox(height: 10)],

            ToolsWidget(selectImages: handleImages),
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
}

class TypeControllerWidget extends ConsumerWidget {
  const TypeControllerWidget({super.key, this.defaultText});

  final String? defaultText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postType = ref.watch(postTypeProvider);
    switch (postType) {
      case PostType.comic_review:
        return const ComicReviewTreeWidget();
      default:
        return PostFieldWidget(defaultText: defaultText);
    }
  }
}
