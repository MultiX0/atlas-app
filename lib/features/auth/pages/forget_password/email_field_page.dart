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
      context.pushReplacement("${Routes.forgotPasswordConfirmEmailPage}/$email");
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Your Password?")),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 25),
        child: CustomButton(text: "Send Reset Code", onPressed: next),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          children: [
            const Text(
              "No worries! Enter your email, and we’ll send you a reset code.",
              style: TextStyle(fontFamily: accentFont, fontSize: 20),
            ),
            const SizedBox(height: 20),
            CustomTextFormField(
              contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
              controller: _emailController,
              hintText: "Please enter your email address.",
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
                    "No account found with this email.",
                    style: TextStyle(
                      fontFamily: accentFont,
                      fontSize: 14,
                      color: AppColors.errorColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String? emailValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'please enter your email';
    }

    if (val.length < 4) {
      return 'please enter valid email address';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(val)) {
      return 'Please enter a valid email address';
    }

    return null;
  }
}
