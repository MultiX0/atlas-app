import 'package:atlas_app/core/common/enum/comment_type.dart';
import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/widgets/markdown_field.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/features/post_comments/controller/post_comments_controller.dart';
import 'package:atlas_app/features/post_comments/providers/providers.dart';
import 'package:atlas_app/features/posts/providers/post_state.dart';
import 'package:atlas_app/imports.dart';

class ChaptersCommentInput extends StatefulWidget {
  const ChaptersCommentInput({super.key, required this.commentType, this.chapterId});
  final CommentType commentType;
  final String? chapterId;

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
              padding: EdgeInsets.zero,
              key: _postFieldKey,
              showUserData: false,
              onMarkupChanged: (text) {
                if (text.length > 500) {
                  CustomToast.error("أقصى طول للتعليق هو 500 حرف");
                  return;
                }
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
                onPressed: () async {
                  if (input.trim().isEmpty) return;
                  if (widget.commentType == CommentType.novel) {
                    final replitedTo = ref.read(repliedToProvider);
                    if (replitedTo == null || replitedTo.isEmpty) {
                      ref
                          .read(novelsControllerProvider.notifier)
                          .addChapterComment(input, chapterId: widget.chapterId!);
                      _postFieldKey.currentState?.clearText();
                      return;
                    }

                    ref
                        .read(novelsControllerProvider.notifier)
                        .replyToComment(
                          commentId: replitedTo[KeyNames.comment_id],
                          replyContent: input,
                          chapterId: widget.chapterId!,
                        );
                  } else if (widget.commentType == CommentType.post) {
                    final replitedTo = ref.read(postCommentRepliedToProvider);
                    final post = ref.read(postStateProvider);
                    if (post == null) {
                      CustomToast.error("خطأ الرجاء اغلاق الصفحة والدخول مجددا ثم اعادة المحاولة");
                      return;
                    }
                    if (replitedTo == null || replitedTo.isEmpty) {
                      ref
                          .read(postCommentsControllerProvider(post.postId).notifier)
                          .addPostComment(content: input, postId: post.postId);
                      _postFieldKey.currentState?.clearText();
                      return;
                    }

                    ref
                        .read(postCommentsControllerProvider(post.postId).notifier)
                        .replyToComment(
                          commentId: replitedTo[KeyNames.comment_id],
                          replyContent: input,
                          postId: post.postId,
                        );
                  } else {}

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
