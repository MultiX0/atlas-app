import 'dart:developer';

import 'package:atlas_app/imports.dart';

class UpdatePassword extends ConsumerStatefulWidget {
  const UpdatePassword({super.key, required this.localUpdate});

  final bool localUpdate;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends ConsumerState<UpdatePassword> {
  late TextEditingController _passwordController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _passwordConfirmationController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _passwordConfirmationController = TextEditingController();
    _passwordController = TextEditingController();
    if (widget.localUpdate) {
      _currentPasswordController = TextEditingController();
    }
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  void next() {
    if (_formKey.currentState!.validate()) {
      if (widget.localUpdate) {
        //TODO LOCAL UPDATE USING THE PAST PASSWORD LOGIC
      } else {
        //TODO UPDATE USING THE VERIFICATION CODE FROM THE EMAIL
      }

      context.pop();
      log("complete");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 25),
        child: CustomButton(
          text: "Update",
          onPressed: next,
          // disabled: acceptTerms,
        ),
      ),
      appBar: AppBar(title: const Text("Create a New Password")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          children: [
            const Text(
              "Enter a strong password to secure your account.",
              style: TextStyle(fontFamily: accentFont, fontSize: 20),
            ),
            const SizedBox(height: Spacing.normalGap),
            if (widget.localUpdate) ...[
              buildCurrentPasswordField(),
              const SizedBox(height: Spacing.normalGap),
            ],
            buildPasswordField(),
            const SizedBox(height: Spacing.normalGap),
            buildConfirmPasswordField(),
            const SizedBox(height: Spacing.normalGap),
          ],
        ),
      ),
    );
  }

  Column buildCurrentPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel("Current Password", size: 15),
        CustomTextFormField(
          prefixIcon: LucideIcons.lock,
          obscureText: true,
          hintText: "Enter Your Password",
          controller: _currentPasswordController,
          validator: (val) => validatePassword(val),
        ),
      ],
    );
  }

  Column buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel("New Password", size: 15),
        CustomTextFormField(
          prefixIcon: LucideIcons.lock,
          obscureText: true,
          hintText: "Enter Your Password",
          controller: _passwordController,
          validator: (val) => validatePassword(val),
        ),
        buildLabel("(Must be at least 8 characters, including a number and a special character.)"),
      ],
    );
  }

  Column buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel("Confirm Password", size: 15),
        CustomTextFormField(
          prefixIcon: LucideIcons.lock,
          hintText: "Enter Your Password Again",
          obscureText: true,
          controller: _passwordConfirmationController,
          validator: (val) => confirmPassword(val, _passwordController.text.trim()),
        ),
        buildLabel("(Must match the first password.)"),
      ],
    );
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password cannot be empty.";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters long.";
    }
    if (!RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,}$').hasMatch(value)) {
      return "Password must include at least\none number and one special character.";
    }
    return null; // Valid
  }

  String? confirmPassword(String? value, String password) {
    if (value != password) {
      return "Passwords do not match.";
    }
    return null; // Valid
  }

  Widget buildLabel(String text, {double size = 14}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        child: Text(
          text,
          style: TextStyle(fontFamily: accentFont, fontSize: size, color: AppColors.mutedSilver),
        ),
      ),
    );
  }
}
