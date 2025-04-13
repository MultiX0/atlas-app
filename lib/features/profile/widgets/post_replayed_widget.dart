import 'package:atlas_app/core/common/widgets/cached_avatar.dart';
import 'package:atlas_app/features/posts/models/post_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class PostReplyedWidget extends StatelessWidget {
  const PostReplyedWidget({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      textDirection:
                          Bidi.hasAnyRtl(post.parent!.content)
                              ? ui.TextDirection.rtl
                              : ui.TextDirection.ltr,
                      post.parent!.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.mutedSilver, fontSize: 12),
                    ),
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
