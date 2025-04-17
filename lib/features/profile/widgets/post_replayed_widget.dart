import 'package:atlas_app/core/common/widgets/cached_avatar.dart';
// import 'package:atlas_app/core/common/widgets/slash_parser.dart';
import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class PostReplyedWidget extends StatelessWidget {
  const PostReplyedWidget({super.key, required this.post});

  final PostModel post;
  // static final parser = buildSlashEntityParser();

  @override
  Widget build(BuildContext context) {
    // final result = parser.parse(post.content);
    // final value = result.value as SlashEntity;

    return RepaintBoundary(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: "ردا على منشور  ",
                        style: const TextStyle(
                          color: AppColors.mutedSilver,
                          fontFamily: arabicAccentFont,
                        ),
                        children: [
                          TextSpan(
                            text: post.parent!.user.username,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontFamily: accentFont,
                            ),
                          ),
                        ],
                      ),
                      textDirection: ui.TextDirection.rtl,
                    ),
                    ReplyedPostContent(post: post),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              CachedAvatar(avatar: post.parent!.user.avatar, raduis: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class ReplyedPostContent extends StatelessWidget {
  const ReplyedPostContent({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textDirection:
          Bidi.hasAnyRtl(post.parent!.content) ? ui.TextDirection.rtl : ui.TextDirection.ltr,

      text: TextSpan(children: _parse(post.parent!.content)),
    );
  }

  List<TextSpan> _parse(String text) {
    final regex = RegExp(r"/(comic|char|novel)\[[^\]]+\]:[^/]+/");
    final matches = regex.allMatches(text);

    List<TextSpan> spans = [];
    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: const TextStyle(color: AppColors.mutedSilver, fontSize: 12),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: match.group(0)?.split(":").last.replaceAll("/", ''),
          style: const TextStyle(color: Colors.blue),
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  //   return Text(
  //     textDirection:
  //         Bidi.hasAnyRtl(post.parent!.content)
  //             ? ui.TextDirection.rtl
  //             : ui.TextDirection.ltr,
  //     post.parent!.content,
  //     maxLines: 1,
  //     overflow: TextOverflow.ellipsis,
  //     style: const TextStyle(color: AppColors.mutedSilver, fontSize: 12),
  //   );
  // }
}
