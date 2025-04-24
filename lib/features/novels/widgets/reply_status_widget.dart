import 'package:atlas_app/core/common/widgets/reuseable_comment_widget.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/imports.dart';

class ReplyStatusWidget extends StatelessWidget {
  const ReplyStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Consumer(
            builder: (context, ref, _) {
              final replitedTo = ref.watch(repliedToProvider);
              if (replitedTo == null || replitedTo.isEmpty) return const SizedBox.shrink();
              if (replitedTo['is_reply'] == null || replitedTo['is_reply'] == false) {
                return const SizedBox.shrink();
              }
              final username = replitedTo[KeyNames.username];
              final content = replitedTo[KeyNames.content];

              return Row(
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
                    },
                    icon: Icon(Icons.close, color: AppColors.whiteColor),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
