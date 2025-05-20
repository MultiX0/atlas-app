import 'dart:developer';

import 'package:atlas_app/features/auth/controller/auth_controller.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FinalRegisterPage extends ConsumerStatefulWidget {
  const FinalRegisterPage({super.key, required this.next, required this.prevs});

  final VoidCallback next;
  final VoidCallback prevs;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FinalRegisterPageState();
}

class _FinalRegisterPageState extends ConsumerState<FinalRegisterPage> {
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmationController;
  final _formKey = GlobalKey<FormState>();
  bool acceptTerms = false;

  @override
  void initState() {
    _passwordConfirmationController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void next() {
    if (_formKey.currentState!.validate()) {
      final localMetaData = ref.read(localUserMetadata);
      final updatedMetaData = localMetaData!.copyWith(password: _passwordController.text.trim());
      ref.read(localUserMetadata.notifier).state = updatedMetaData;
      final localUser = ref.read(localUserModel);
      ref.read(localUserModel.notifier).state = localUser!.copyWith(metadata: updatedMetaData);

      ref.read(authControllerProvider.notifier).signUp();
      log("complete");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        widget.prevs();
      },
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 25),
          child: CustomButton(
            text: "التسجيل",
            fontSize: 16,
            onPressed: acceptTerms ? () => next() : null,
            isLoading: isLoading,
            // disabled: acceptTerms,
          ),
        ),
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              widget.prevs();
            },
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              children: [
                const Text(
                  "أنشئ كلمة مرور قوية ووافق على شروطنا للمتابعة.",
                  style: TextStyle(fontFamily: arabicAccentFont, fontSize: 24),
                ),
                const SizedBox(height: Spacing.normalGap),
                buildPasswordField(),
                const SizedBox(height: Spacing.normalGap),
                buildConfirmPasswordField(),
                const SizedBox(height: Spacing.normalGap),
                buildTermsCheckbox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          activeColor: AppColors.primary,
          value: acceptTerms,
          onChanged: (val) {
            setState(() {
              acceptTerms = val!;
            });
            log(acceptTerms.toString());
          },
        ),
        Expanded(
          child: Text.rich(
            softWrap: true,
            TextSpan(
              text: "أوافق على ",
              children: [
                TextSpan(
                  text: 'شروط الخدمة',
                  style: const TextStyle(color: AppColors.primary),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () async {
                          await launchUrlString('https://www.atlasapp.app/terms');
                        },
                ),
                const TextSpan(text: " و "),
                TextSpan(
                  text: "سياسة الخصوصية",
                  style: const TextStyle(color: AppColors.primary),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () async {
                          await launchUrlString('https://www.atlasapp.app/privacy');
                        },
                ),
              ],
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.mutedSilver,
              fontFamily: arabicAccentFont,
            ),
          ),
        ),
      ],
    );
  }

  Column buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel("كلمة المرور", size: 15),
        CustomTextFormField(
          prefixIcon: LucideIcons.lock,
          obscureText: true,
          hintText: "أدخل كلمة المرور الخاصة بك",
          controller: _passwordController,
          validator: (val) => validatePassword(val),
        ),
        buildLabel(
          "(يجب أن تكون كلمة المرور مكونة من 8 أحرف على الأقل، بما في ذلك رقم ورمز خاص. مثل # - \$ - @)",
        ),
      ],
    );
  }

  Column buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel("تأكيد كلمة المرور", size: 15),
        CustomTextFormField(
          prefixIcon: LucideIcons.lock,
          hintText: "أدخل كلمة المرور الخاصة بك مرة أخرى",
          obscureText: true,
          controller: _passwordConfirmationController,
          validator: (val) => confirmPassword(val, _passwordController.text.trim()),
        ),
        buildLabel("(يجب أن تتطابق مع كلمة المرور الأولى.)"),
      ],
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
      return "يجب أن تتضمن كلمة المرور على الأقل رقمًا واحدًا ورمزًا خاصًا واحدًا. مثل # أو @ أو \$";
    }
    return null; // Valid
  }

  String? confirmPassword(String? value, String password) {
    if (value != password) {
      return "كلمات المرور غير متطابقة.";
    }
    return null; // Valid
  }

  Widget buildLabel(String text, {double size = 14}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: arabicAccentFont,
            fontSize: size,
            color: AppColors.mutedSilver,
          ),
        ),
      ),
    );
  }
}
