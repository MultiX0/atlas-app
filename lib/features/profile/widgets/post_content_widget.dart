import 'dart:developer';

import 'package:atlas_app/core/common/widgets/rich_text_view/models.dart';
import 'package:atlas_app/core/common/widgets/rich_text_view/text_view.dart';
import 'package:atlas_app/core/common/widgets/slash_parser.dart';
import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class PostContentWidget extends ConsumerWidget {
  final String? hashtag;
  const PostContentWidget({super.key, required this.post, this.hashtag});

  final PostModel post;
  bool get hasArabic => Bidi.hasAnyRtl(post.content);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: RepaintBoundary(
        child: RichTextView(
          key: ValueKey(post.postId),
          textDirection: hasArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          text: post.content,
          maxLines: 20,
          truncate: true,
          style: TextStyle(fontWeight: FontWeight.w300, color: AppColors.whiteColor),
          viewLessText: 'أقل',
          viewMoreText: "المزيد",
          linkStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          supportedTypes: [
            EmailParser(onTap: (email) => log('${email.value} clicked')),
            PhoneParser(onTap: (phone) => log('click phone ${phone.value}')),
            MentionParser(onTap: (mention) => log('${mention.value} clicked')),
            BoldParser(),
            HashTagParser(
              onTap: (hash) {
                final _validHashtag = hash.value?.split('#').last;
                log(_validHashtag.toString());
                log(hashtag.toString());
                if (hashtag == _validHashtag) {
                  return;
                }

                ref.read(navsProvider).goToHashtagPage(_validHashtag ?? "unknown");
              },
            ),
            SlashEntityParser(
              onTap: (matched) {
                final parts = matched.value?.split(":");
                final type = parts?[0];
                final id = parts?[1];
                final title = parts?.sublist(2).join(":"); // Handles ':' in title

                switch (type) {
                  case 'comic':
                    log('Open Comic (ID: $id) → $title');
                    // Navigator.pushNamed(context, '/comic/$id');
                    break;
                  case 'char':
                    log('Open Character (ID: $id) → $title');
                    break;
                  case 'novel':
                    log('Open Novel (ID: $id) → $title');
                    break;
                }
              },
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
