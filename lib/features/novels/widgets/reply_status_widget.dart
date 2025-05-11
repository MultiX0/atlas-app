import 'package:atlas_app/core/common/enum/comment_type.dart';
import 'package:atlas_app/core/common/widgets/reuseable_comment_widget.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/features/post_comments/providers/providers.dart';
import 'package:atlas_app/imports.dart';

class ReplyStatusWidget extends StatelessWidget {
  const ReplyStatusWidget({super.key, required this.commentType});

  final CommentType commentType;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Consumer(
            builder: (context, ref, _) {
              Map<String, dynamic>? replitedTo;

              if (commentType == CommentType.novel) {
                replitedTo = ref.watch(repliedToProvider);
              } else if (commentType == CommentType.post) {
                replitedTo = ref.watch(postCommentRepliedToProvider);
              } else {
                replitedTo = null;
              }
              if (replitedTo == null || replitedTo.isEmpty) return const SizedBox.shrink();
              if (replitedTo['is_reply'] == null || replitedTo['is_reply'] == false) {
                return const SizedBox.shrink();
              }

              final username = replitedTo[KeyNames.username];
              final content = replitedTo[KeyNames.content];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "رد على $username",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontFamily: arabicAccentFont,
                            ),
                          ),
                          CommentRichTextView(
                            text: content,
                            style: const TextStyle(
                              color: AppColors.mutedSilver,
                              fontFamily: arabicAccentFont,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ref.read(repliedToProvider.notifier).state = null;
                        ref.read(postCommentRepliedToProvider.notifier).state = null;
                      },
                      icon: Icon(Icons.close, color: AppColors.whiteColor),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
