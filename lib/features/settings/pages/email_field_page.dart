import 'package:atlas_app/imports.dart';
import 'package:flutter/services.dart';

class EmailFieldPage extends ConsumerStatefulWidget {
  const EmailFieldPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EmailFieldPageState();
}

class _EmailFieldPageState extends ConsumerState<EmailFieldPage> {
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  bool isValidEmail = true;
  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void next() {
    final email = _emailController.text.trim().toLowerCase();
    if (_formKey.currentState!.validate()) {
      if (email != "shwiamahommed@gmail.com") {
        setState(() {
          isValidEmail = false;
        });
        return;
      }
      setState(() {
        isValidEmail = true;
      });
      context.pushReplacementNamed(
        Routes.forgotPassword,
        extra: {'email': _emailController.text.trim()},
      );
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("نسيت كلمة المرور؟")),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 25),
        child: CustomButton(text: "إرسال رمز التأكيد", onPressed: () => next()),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
            children: [
              const Text(
                "لا تقلق! أدخل بريدك الإلكتروني وسنرسل لك رمز إعادة التعيين.",
                style: TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                controller: _emailController,
                hintText: "يرجى إدخال عنوان بريدك الإلكتروني.",
                prefixIcon: LucideIcons.mail,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9.@_\-+]'))],
                validator: (val) => emailValidator(val),
              ),
              const SizedBox(height: 15),

              if (!isValidEmail)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    child: Text(
                      "لم يتم العثور على حساب بهذا البريد الإلكتروني.",
                      style: TextStyle(
                        fontFamily: arabicAccentFont,
                        fontSize: 14,
                        color: AppColors.errorColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? emailValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'يرجى إدخال بريدك الإلكتروني.';
    }

    if (val.length < 4) {
      return 'يرجى إدخال عنوان بريد إلكتروني صالح.';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(val)) {
      return 'يرجى إدخال عنوان بريد إلكتروني صالح.';
    }

    return null;
  }
}
