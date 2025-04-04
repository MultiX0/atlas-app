import 'dart:developer';

import 'package:atlas_app/features/auth/controller/auth_controller.dart';
import 'package:atlas_app/imports.dart';

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

      //TODO IMPLEMENT BACKEND CODE HERE
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
            text: "Continue",
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
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            children: [
              const Text(
                "Create a strong password and agree to our terms to continue.",
                style: TextStyle(fontFamily: accentFont, fontSize: 20),
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
        const Expanded(
          child: Text.rich(
            softWrap: true,
            TextSpan(
              text: "I agree to the ",
              children: [
                TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.primary)),
                TextSpan(text: " and "),
                TextSpan(text: "Privacy Policy", style: TextStyle(color: AppColors.primary)),
              ],
            ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.mutedSilver,
              fontFamily: accentFont,
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
        buildLabel("Password", size: 15),
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
