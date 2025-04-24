import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/features/posts/providers/providers.dart';
import 'package:atlas_app/features/reports/db/reports_db.dart';
import 'package:atlas_app/features/reports/models/post_report_model.dart';
import 'package:atlas_app/imports.dart';

class PostReportSheet extends StatelessWidget {
  const PostReportSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTitle(),
        Expanded(child: ListView(children: [buildActionList(context)])),
      ],
    );
  }

  Widget buildActionList(BuildContext context) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
      color: AppColors.scaffoldBackground,
    ),
    child: Material(
      color: Colors.transparent,
      child: Consumer(
        builder: (context, ref, _) {
          return Column(
            children: [
              buildTile("محتوى مسيء", subtitle: " يحتوي على كلمات أو عبارات غير محترمة."),
              buildTile(subtitle: " يتضمن تمييزًا أو تحريضًا على العنف.", "خطاب كراهية أو تحريض"),
              buildTile(subtitle: " يتضمن صورًا أو عبارات غير مناسبة.", "محتوى غير لائق أو إباحي"),
              buildTile(subtitle: " تم نشر هذا المحتوى عدة مرات أو بشكل عشوائي.", "مزعج أو مكرر"),
              buildTile(subtitle: " منشور منسوخ من جهة أخرى بدون إذن.", "انتهاك حقوق النشر"),
              buildTile(subtitle: " يتضمن أخبارًا أو معلومات غير صحيحة.", "معلومات كاذبة أو مضللة"),
              buildTile(subtitle: "  يحتوي على إعلان لمنتج أو خدمة.", "دعاية أو ترويج"),
              buildTile(subtitle: "  يهاجم أو يزعج أحد المستخدمين.", "تنمّر أو مضايقة"),
              buildTile(
                subtitle: "سبب آخر",
                " سبب مختلف (يرجى التوضيح).",
                onTap: () => openConfirmSheet(context),
              ),
            ],
          );
        },
      ),
    ),
  );

  void openConfirmSheet(BuildContext context, {String? title, String? subtitle}) {
    context.pop();
    openSheet(
      context: context,
      child: PostReportConfirmation(subtitle: subtitle, title: title),
      scrollControlled: true,
    );
  }

  Widget buildTile(String text, {Function()? onTap, required String subtitle}) {
    return Builder(
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListTile(
            onTap: () {
              if (onTap == null) {
                openConfirmSheet(context, subtitle: subtitle, title: text);
              } else {
                onTap();
              }
            },
            title: Row(children: [Text(text)]),
            subtitle: Text(
              subtitle,
              style: const TextStyle(color: AppColors.mutedSilver, fontFamily: arabicPrimaryFont),
            ),

            titleTextStyle: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
          ),
        );
      },
    );
  }

  Widget buildTitle() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 25),
    child: Column(
      children: [
        Center(
          child: Text(
            'الإبلاغ عن منشور',
            style: TextStyle(fontFamily: arabicAccentFont, fontSize: 24),
          ),
        ),
        Center(
          child: Text(
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            "ساعدنا في الحفاظ على مجتمع Atlas\n آمنًا ومحترما للجميع عبر اختيار سبب البلاغ أدناه.",
            style: TextStyle(
              fontFamily: arabicAccentFont,
              fontSize: 14,
              color: AppColors.mutedSilver,
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    ),
  );
}

class PostReportConfirmation extends StatefulWidget {
  const PostReportConfirmation({super.key, this.subtitle, this.title});

  final String? title;
  final String? subtitle;

  @override
  State<PostReportConfirmation> createState() => _PostReportConfirmationState();
}

class _PostReportConfirmationState extends State<PostReportConfirmation> {
  late TextEditingController _controller;
  @override
  void initState() {
    if (widget.title == null && widget.subtitle == null) {
      _controller = TextEditingController();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.title == null && widget.subtitle == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.subtitle == null && widget.title == null) ...[
              const Text(
                "توضيح",
                style: TextStyle(
                  fontFamily: arabicAccentFont,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              CustomTextFormField(
                controller: _controller,
                maxLength: 256,
                hintText:
                    'الرجاء ادخال سبب البلاغ الخاص بك, عليك معرفة أن بلاغك يهمنا وسوف نقوم بالتدابير اللازمة في حال ما اذا كان هنالك أي مشاكل',
                maxLines: 3,
                minLines: 3,
              ),
            ] else ...[
              Text(
                widget.title!,
                style: const TextStyle(fontFamily: arabicAccentFont, fontSize: 20),
              ),
              Text(
                widget.subtitle!,
                style: const TextStyle(
                  fontFamily: arabicAccentFont,
                  fontSize: 14,
                  color: AppColors.mutedSilver,
                ),
              ),
            ],
            const SizedBox(height: 25),
            Consumer(
              builder: (context, ref, _) {
                return CustomButton(
                  text: "تسليم البلاغ",
                  onPressed: () {
                    String reason;
                    if (widget.title == null && widget.subtitle == null) {
                      reason = _controller.text.trim();
                      if (reason.length < 20) {
                        CustomToast.error("محتوى البلاغ يجب أن يكون 20 حرف أو أكثر");
                      }
                    } else {
                      reason = widget.subtitle!;
                    }
                    final post = ref.read(selectedPostProvider)!;
                    final me = ref.read(userState.select((state) => state.user!));
                    final report = PostReportModel(
                      content: reason,
                      postId: post.postId,
                      userId: me.userId,
                    );

                    ref.read(reportsDbProvider).newReport(report);
                    context.pop();
                    CustomToast.success("تم تقديم البلاغ بنجاح, نشكرك على مساهمتك");
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
