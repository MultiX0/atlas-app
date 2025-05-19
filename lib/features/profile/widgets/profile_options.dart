import 'dart:developer';
import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/features/auth/controller/auth_controller.dart';
import 'package:atlas_app/features/reports/db/reports_db.dart';
import 'package:atlas_app/imports.dart';
import 'package:share_plus/share_plus.dart';

class UserProfileOptions extends StatefulWidget {
  const UserProfileOptions({super.key, required this.isMe, required this.user});

  final bool isMe;
  final UserModel user;

  @override
  State<UserProfileOptions> createState() => _UserProfileOptionsState();
}

class _UserProfileOptionsState extends State<UserProfileOptions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [buildTitle(), buildActionList(context, isMe: widget.isMe)],
    );
  }

  Widget buildActionList(BuildContext context, {required bool isMe}) => Container(
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
              buildTile(
                "ابلاغ",
                visible: !isMe,
                LucideIcons.flag,
                onTap: () {
                  context.pop();
                  openSheet(
                    context: context,
                    child: UserReportSheet(user: widget.user),
                    scrollControlled: true,
                  );
                  log("Report user clicked");
                },
              ),
              buildTile(
                "تسجيل الخروج",
                visible: isMe,
                LucideIcons.log_out,
                onTap: () {
                  context.pop();
                  alertDialog();
                },
              ),
              buildTile(
                "نسخ الرابط",
                LucideIcons.link_2,
                onTap: () {
                  Share.share(
                    "📖 اكتشف ملفي الشخصي على أطلس!\n\nتابعني على أطلس واستمتع بأعمالي ومشاركتي الأدبية والفنية:\n$subAppDomain${Routes.user}/${widget.user.userId}\n\nانضم إلى أطلس الآن وابدأ رحلتك الإبداعية!",
                  );

                  // CustomToast.success("تم نسخ رابط الملف الشخصي بنجاح");
                  context.pop();
                },
              ),
            ],
          );
        },
      ),
    ),
  );

  void alertDialog() {
    const btnStyle = TextStyle(fontFamily: arabicAccentFont, color: AppColors.primary);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryAccent,
          title: const Text(
            textDirection: TextDirection.rtl,
            "هل أنت متأكد من تسجيل الخروج؟",
            style: TextStyle(fontFamily: arabicAccentFont),
          ),
          content: const Text(
            'سيتم تسجيل خروجك من التطبيق. يمكنك تسجيل الدخول مرة أخرى في أي وقت.',
            style: TextStyle(fontFamily: arabicPrimaryFont),
            textDirection: TextDirection.rtl,
          ),
          actions: [
            Consumer(
              builder: (context, ref, _) {
                return TextButton(
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).logout();
                    context.pop();
                  },
                  child: const Text("تسجيل الخروج", style: btnStyle),
                );
              },
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

  Widget buildTile(String text, IconData icon, {required Function() onTap, bool visible = true}) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListTile(
        onTap: onTap,
        title: Row(children: [Text(text)]),
        leading: Icon(icon, color: AppColors.mutedSilver),
        titleTextStyle: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
      ),
    );
  }

  Widget buildTitle() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 25),
    child: Text('الخيارات', style: TextStyle(fontFamily: arabicAccentFont, fontSize: 24)),
  );
}

class UserReportSheet extends StatefulWidget {
  final UserModel user;

  const UserReportSheet({super.key, required this.user});

  @override
  State<UserReportSheet> createState() => _UserReportSheetState();
}

class _UserReportSheetState extends State<UserReportSheet> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, String>> _reportReasons = [
    {
      'reason': 'محتوى غير لائق',
      'description': 'مثل المحتوى الجنسي الصريح، العنف المفرط، أو خطاب الكراهية',
    },
    {'reason': 'التحرش أو التنمر', 'description': 'التهديدات، الإساءات، أو المضايقات ضد الأفراد'},
    {'reason': 'انتحال الشخصية', 'description': 'التظاهر بأنك شخص آخر أو كيان'},
    {
      'reason': 'انتهاك الملكية الفكرية',
      'description': 'نشر محتوى ينتهك حقوق النشر أو الملكية الفكرية',
    },
    {'reason': 'أخرى', 'description': 'أي سبب آخر غير مدرج'},
  ];

  void _submitReport(WidgetRef ref) async {
    if (_selectedReason == null) {
      CustomToast.error("يرجى اختيار سبب الإبلاغ");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final me = ref.read(userState).user!;
      ref
          .read(reportsDbProvider)
          .addUserReport(
            reported_id: widget.user.userId,
            reporter_id: me.userId,
            reason: _selectedReason ?? "",
            details: _detailsController.text.trim(),
          );
      CustomToast.success("تم إرسال الإبلاغ بنجاح");
      // ignore: use_build_context_synchronously
      context.pop();
    } catch (e) {
      CustomToast.error("فشل إرسال الإبلاغ. حاول مرة أخرى.");
      log("Error submitting report: $e");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,

          child: ListView(
            children: [
              const Text(
                "يرجى اختيار سبب الإبلاغ:",
                style: TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ..._reportReasons.map(
                (reason) => RadioListTile<String>(
                  title: Text(
                    reason['reason']!,
                    style: const TextStyle(fontFamily: arabicPrimaryFont),
                  ),
                  subtitle: Text(
                    reason['description']!,
                    style: const TextStyle(
                      fontFamily: arabicPrimaryFont,
                      color: AppColors.mutedSilver,
                    ),
                  ),
                  value: reason['reason']!,
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              CustomTextFormField(
                hintText: "أدخل تفاصيل إضافية عن الإبلاغ",
                controller: _detailsController,
                maxLines: 3,
                maxLength: 512,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      "إلغاء",
                      style: TextStyle(fontFamily: arabicAccentFont, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer(
                    builder: (context, ref, _) {
                      return ElevatedButton(
                        onPressed: () => _isSubmitting ? null : _submitReport(ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child:
                            _isSubmitting
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  "إرسال",
                                  style: TextStyle(
                                    fontFamily: arabicAccentFont,
                                    color: Colors.white,
                                  ),
                                ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
