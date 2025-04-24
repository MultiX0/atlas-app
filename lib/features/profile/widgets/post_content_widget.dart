import 'package:atlas_app/core/common/widgets/reuseable_comment_widget.dart';
import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class PostContentWidget extends ConsumerWidget {
  final String? hashtag;
  const PostContentWidget({super.key, required this.post, this.hashtag, this.repost = false});

  final bool repost;
  final PostModel post;
  bool get hasArabic => Bidi.hasAnyRtl(post.content);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: RepaintBoundary(
        child: CommentRichTextView(
          key: ValueKey(post.postId),
          text: post.content,
          maxLines: repost ? 3 : 20,
        ),
      ),
    );
  }

  void alertDialog(BuildContext context, String url) {
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
            'لقد نقرت على رابط لا ينتمي إلى atlasmanga.app. زيارة مواقع غير موثوقة قد تعرضك للتصيد الاحتيالي أو البرمجيات الخبيثة. تأكد من أن الرابط يبدأ بـ "atlasmanga.app" قبل المتابعة. إذا كان مشبوهًا، ارجع إلى التطبيق.',
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
