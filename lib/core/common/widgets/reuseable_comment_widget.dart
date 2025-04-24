import 'dart:developer';

import 'package:atlas_app/core/common/widgets/rich_text_view/models.dart';
import 'package:atlas_app/core/common/widgets/rich_text_view/text_view.dart';
import 'package:atlas_app/core/common/widgets/slash_parser.dart';
import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class CommentRichTextView extends StatelessWidget {
  final String text;
  final int? maxLines;
  final bool truncate;
  final TextStyle? style;
  final String viewLessText;
  final String viewMoreText;
  final TextStyle? linkStyle;

  const CommentRichTextView({
    super.key,
    required this.text,
    this.maxLines = 3,
    this.truncate = true,
    this.style,
    this.viewLessText = 'أقل',
    this.viewMoreText = 'المزيد',
    this.linkStyle,
  });
  bool get hasArabic => Bidi.hasAnyRtl(text);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return RichTextView(
          text: text,
          maxLines: maxLines,
          truncate: truncate,
          textDirection: hasArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,

          style:
              style ??
              TextStyle(
                fontWeight: FontWeight.w300,
                color: AppColors.whiteColor,
                fontFamily: arabicPrimaryFont,
              ),
          viewLessText: viewLessText,
          viewMoreText: viewMoreText,
          linkStyle:
              linkStyle ?? const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          supportedTypes: [
            EmailParser(onTap: (email) => log('${email.value} clicked')),
            PhoneParser(onTap: (phone) => log('click phone ${phone.value}')),
            MentionParser(onTap: (mention) => log('${mention.value} clicked')),
            UrlParser(
              onTap: (url) {
                final regex = RegExp(r'^(https?://)?([a-zA-Z0-9-]+\.)?atlasmanga\.app(/.*)?$');
                if (regex.hasMatch(url.value ?? "")) {
                  log("valid app domain");
                } else {
                  _showAlertDialog(context, url.value ?? "");
                }
              },
            ),
            BoldParser(),
            HashTagParser(
              onTap: (hash) {
                final validHashtag = hash.value?.split('#').last;
                log(validHashtag.toString());
                ref.read(navsProvider).goToHashtagPage(validHashtag ?? "unknown");
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
                    context.push("${Routes.novelPage}/$id");
                    break;
                }
              },
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }

  void _showAlertDialog(BuildContext context, String url) {
    const btnStyle = TextStyle(fontFamily: arabicAccentFont, color: AppColors.primary);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryAccent,
          title: const Text(
            textDirection: ui.TextDirection.rtl,
            "تحذير: رابط غير موثوق",
            style: TextStyle(fontFamily: arabicAccentFont),
          ),
          content: const Text(
            'لقد نقرت على رابط لا ينتمي إلى atlasapp.app. زيارة مواقع غير موثوقة قد تعرضك للتصيد الاحتيالي أو البرمجيات الخبيثة. تأكد من أن الرابط يبدأ بـ "atlasapp.app" قبل المتابعة. إذا كان مشبوهًا، ارجع إلى التطبيق.',
            style: TextStyle(fontFamily: arabicPrimaryFont),
            textDirection: ui.TextDirection.rtl,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                context.pop();
                await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
              },
              child: const Text("الااستمرار", style: btnStyle),
            ),
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("عودة", style: btnStyle),
            ),
          ],
        );
      },
    );
  }
}
