import 'package:atlas_app/core/common/widgets/markdown_field.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/imports.dart';

class ChaptersCommentInput extends StatefulWidget {
  const ChaptersCommentInput({super.key});

  @override
  State<ChaptersCommentInput> createState() => _ChaptersCommentInputState();
}

class _ChaptersCommentInputState extends State<ChaptersCommentInput> {
  String input = '';
  final GlobalKey<ReusablePostFieldWidgetState> _postFieldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
      child: Row(
        children: [
          Expanded(
            child: ReusablePostFieldWidget(
              key: _postFieldKey,
              showUserData: false,
              onMarkupChanged: (text) {
                setState(() {
                  input = text;
                });
              },
              minLines: 1,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 10),
          Consumer(
            builder: (context, ref, _) {
              return IconButton(
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  if (input.trim().isEmpty) return;
                  ref.read(novelsControllerProvider.notifier).addChapterComment(input);
                  _postFieldKey.currentState?.clearText();
                },
                icon: const Icon(TablerIcons.send_2),
              );
            },
          ),
        ],
      ),
    );
  }
}
