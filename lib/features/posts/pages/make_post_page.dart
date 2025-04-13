import 'dart:developer';
import 'dart:io';
import 'package:atlas_app/features/posts/providers/providers.dart';
import 'package:atlas_app/features/posts/widgets/comic_review_tree_widget.dart';
import 'package:atlas_app/features/posts/widgets/post_field_widget.dart';
import 'package:atlas_app/features/posts/widgets/tools_widget.dart';
import 'package:atlas_app/imports.dart';

// Main page widget
class MakePostPage extends ConsumerStatefulWidget {
  const MakePostPage({super.key, required this.postType});

  final PostType postType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MakePostPageState();
}

class _MakePostPageState extends ConsumerState<MakePostPage> {
  late TextEditingController _controller;
  List<Map<String, dynamic>> mentionSuggestions = [];
  List<File> selectedImages = [];

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
                  log("the final data is $data");
                },
                icon: const Icon(LucideIcons.check),
              ),
            ),
          ),
        ],
      ),
      body: const Column(
        children: [
          Expanded(child: SingleChildScrollView(child: TypeControllerWidget())),
          ToolsWidget(),
        ],
      ),
    );
  }
}

class TypeControllerWidget extends ConsumerWidget {
  const TypeControllerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postType = ref.watch(postTypeProvider);
    switch (postType) {
      case PostType.comic_review:
        return const ComicReviewTreeWidget();
      default:
        return const PostFieldWidget();
    }
  }
}
