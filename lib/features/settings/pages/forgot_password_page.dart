// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:atlas_app/features/auth/controller/auth_controller.dart';
import 'package:atlas_app/features/settings/widgets/settings_header.dart';
import 'package:flutter/services.dart';
import 'package:atlas_app/imports.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  late TextEditingController verificationCodeController;
  late TextEditingController passwordController;
  late TextEditingController repasswordController;
  late Timer _timer;
  String? userId;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    verificationCodeController = TextEditingController();
    passwordController = TextEditingController();
    repasswordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initTimer();
    });
    super.initState();
  }

  @override
  void dispose() {
    verificationCodeController.dispose();
    passwordController.dispose();
    repasswordController.dispose();
    _timer.cancel();
    super.dispose();
  }

  int duration = 0;

  void initTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final d = prefs.getInt("forgot_password_timer") ?? 60;
    setState(() {
      duration = d;
    });

    if (d == 0) {
      resend();
    }

    if (duration > 1) {
      startTimer();
    }
  }

  void resend() {
    ref
        .read(authControllerProvider.notifier)
        .sendOTP(email: widget.email.toLowerCase().trim(), name: "");
    log(widget.email);
    setState(() {
      duration = 0;
    });
    return startTimer();
  }

  RegExp get emailRegex => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  Future<bool> checkTheCode() async {
    return true;
  }

  void handleRequest() async {
    try {
      if (_formKey.currentState!.validate()) {
        await ref
            .read(authControllerProvider.notifier)
            .verificationCheck(
              email: widget.email,
              password: passwordController.text.trim(),
              verificationCode: verificationCodeController.text.trim(),
            );
        context.pop();
      }
    } catch (e) {
      rethrow;
    }
  }

  void startTimer() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      duration = duration > 0 ? duration : 60;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (duration > 0) {
          setState(() {
            duration--;
          });
          prefs.setInt("forgot_password_timer", duration);
          log(duration.toString());
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSizes.normalPadding,
            children: [
              const SettingsHeader(
                title: "نسيت كلمة المرور",

                description:
                    'سنرسل لك رمز تحقق للتأكد من أنك مالك الحساب. تأكد من اختيار كلمة مرور قوية تحتوي على مزيج من الأرقام والحروف والرموز الخاصة (!@%).',
              ),
              GestureDetector(
                onTap: resend,
                child: Text(
                  "إعادة إرسال الرمز ${duration != 0 ? "بعد $duration" : ''}",
                  style: TextStyle(
                    fontSize: 14,
                    color: duration != 0 ? Colors.white60 : AppColors.primary,
                    fontFamily: arabicAccentFont,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              CustomTextFormField(
                hintText: "رمز التحقق",
                controller: verificationCodeController,
                obscureText: false,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'أدخل رمز التحقق';
                  }
                  if (value.length != 6) {
                    return 'يجب أن يتكون رمز التحقق من 6 أرقام.';
                  }
                  return null;
                },
                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
              ),
              const SizedBox(height: 10),

              CustomTextFormField(
                hintText: "كلمة المرور الجديدة",
                controller: passwordController,
                obscureText: true,
                maxLength: 32,
                validator: validatePassword,
                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                hintText: "أعد كتابة كلمة المرور الجديدة",
                controller: repasswordController,
                obscureText: true,
                maxLength: 32,
                validator: (val) => confirmPassword(val, passwordController.text.trim()),
                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(25),
        child: CustomButton(
          text: "تغيير كلمة المرور",
          isLoading: isLoading,
          onPressed: handleRequest,
          backgroundColor: AppColors.whiteColor,
          textColor: AppColors.blackColor,
        ),
      ),
    );
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "كلمة المرور لا يمكن أن تكون فارغة.";
    }
    if (value.length < 8) {
      return "يجب أن تكون كلمة المرور مكونة من 8 أحرف على الأقل.";
    }
    if (!RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,}$').hasMatch(value)) {
      return "يجب أن تتضمن كلمة المرور على الأقل رقمًا واحدًا ورمزًا خاصًا واحدًا.";
    }
    return null; // Valid
  }

  String? confirmPassword(String? value, String password) {
    if (value != password) {
      return "كلمات المرور غير متطابقة.";
    }
    return null; // Valid
  }
}
