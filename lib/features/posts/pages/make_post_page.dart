import 'dart:developer';
import 'dart:io';
import 'package:atlas_app/features/posts/db/posts_db.dart';
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
                onPressed: () async {
                  if (inputVal.trim().isEmpty) {
                    return;
                  }
                  final data = ref.read(postInputProvider);
                  log("post input: $data");
                  final _post = PostsDb();
                  final me = ref.read(userState).user!.userId;
                  await _post.insertPost(data, me);
                  // ignore: use_build_context_synchronously
                  context.pop();
                },
                icon: const Icon(LucideIcons.check),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: TypeControllerWidget(defaultText: widget.defaultText),
            ),
          ),
          const ToolsWidget(),
        ],
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
