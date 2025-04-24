import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/imports.dart';

typedef ReportSubmitCallback = void Function(String reason);

class ReportSheet extends StatelessWidget {
  const ReportSheet({
    super.key,
    required this.title,
    required this.reasons,
    required this.onSubmit,
    this.showCustomReason = true,
  });

  final String title;
  final List<ReportReason> reasons;
  final ReportSubmitCallback onSubmit;
  final bool showCustomReason;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTitle(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
                    color: AppColors.scaffoldBackground,
                  ),
                  child: Column(
                    children: [
                      ...reasons.map((reason) => buildTile(context, reason)),
                      if (showCustomReason)
                        buildTile(
                          context,
                          const ReportReason(
                            title: "سبب مختلف",
                            subtitle: "سبب آخر (يرجى التوضيح)",
                            isCustom: true,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTitle() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Column(
      children: [
        Center(
          child: Text(title, style: const TextStyle(fontFamily: arabicAccentFont, fontSize: 24)),
        ),
        const Center(
          child: Text(
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            "ساعدنا في الحفاظ على المجتمع آمنًا ومحترمًا للجميع عبر اختيار سبب البلاغ أدناه.",
            style: TextStyle(
              fontFamily: arabicAccentFont,
              fontSize: 14,
              color: AppColors.mutedSilver,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    ),
  );

  Widget buildTile(BuildContext context, ReportReason reason) {
    return ListTile(
      onTap:
          () =>
              reason.isCustom
                  ? openCustomReason(context)
                  : openConfirmSheet(context, reason.title, reason.subtitle),
      title: Row(children: [Text(reason.title)]),
      subtitle: Text(
        reason.subtitle,
        style: const TextStyle(color: AppColors.mutedSilver, fontFamily: arabicPrimaryFont),
      ),
      titleTextStyle: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
    );
  }

  void openConfirmSheet(BuildContext context, String title, String subtitle) {
    context.pop();
    openSheet(
      context: context,
      child: ReportConfirmation(title: title, subtitle: subtitle, onSubmit: onSubmit),
      scrollControlled: true,
    );
  }

  void openCustomReason(BuildContext context) {
    context.pop();
    openSheet(
      context: context,
      child: ReportConfirmation(onSubmit: onSubmit),
      scrollControlled: true,
    );
  }
}

class ReportReason {
  final String title;
  final String subtitle;
  final bool isCustom;
  const ReportReason({required this.title, required this.subtitle, this.isCustom = false});
}

class ReportConfirmation extends StatefulWidget {
  const ReportConfirmation({super.key, this.title, this.subtitle, required this.onSubmit});

  final String? title;
  final String? subtitle;
  final ReportSubmitCallback onSubmit;

  @override
  State<ReportConfirmation> createState() => _ReportConfirmationState();
}

class _ReportConfirmationState extends State<ReportConfirmation> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = widget.title == null && widget.subtitle == null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 25).add(MediaQuery.of(context).viewInsets),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCustom) ...[
              const Text("توضيح", style: TextStyle(fontFamily: arabicAccentFont, fontSize: 24)),
              const SizedBox(height: 15),
              CustomTextFormField(
                controller: _controller,
                maxLength: 256,
                maxLines: 3,
                minLines: 3,
                hintText: 'يرجى إدخال سبب البلاغ، سيتم مراجعته بعناية.',
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
            CustomButton(
              text: "تسليم البلاغ",
              onPressed: () {
                String reason = isCustom ? _controller.text.trim() : widget.subtitle!;
                if (isCustom && reason.length < 20) {
                  return CustomToast.error("البلاغ يجب أن يحتوي على 20 حرفًا على الأقل");
                }
                widget.onSubmit(reason);
                context.pop();
                CustomToast.success("تم تقديم البلاغ بنجاح، شكرًا لمساهمتك!");
              },
            ),
          ],
        ),
      ),
    );
  }
}
