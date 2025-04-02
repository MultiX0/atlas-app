import 'dart:developer';

import 'package:atlas_app/core/common/widgets/or_widget.dart';
import 'package:atlas_app/features/auth/controller/auth_controller.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/services.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (_formKey.currentState!.validate()) {
      log("login");
      //TODO LOGIN LOGIC HERE
      ref
          .read(authControllerProvider.notifier)
          .login(email: _emailController.text.trim(), password: _passwordController.text.trim());

      // context.pushReplacement(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        children: [
          const LinesPattren(),
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    shrinkWrap: true,
                    children: [
                      const AppLogoWidget(),
                      const SizedBox(height: 25),
                      const Text(
                        "Sign in to Atlas",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: accentFont, fontSize: 25),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Connect with a community of manga and manhwa enthusiasts. Discover original works, engage in discussions, and support independent creators.",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * .05),
                      CustomTextFormField(
                        controller: _emailController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9.@_\-+]')),
                        ],
                        validator: (val) => emailValidator(val),

                        hintText: "Enter your email adress",
                        prefixIcon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: size.height * .025),
                      CustomTextFormField(
                        controller: _passwordController,
                        hintText: "password",
                        validator: (val) => passwordValidator(val),
                        prefixIcon: LucideIcons.lock,
                        obscureText: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => context.push(Routes.forgotPasswordEmailPage),
                          child: Text(
                            "Forgot your password?",
                            style: TextStyle(
                              fontFamily: accentFont,
                              fontSize: 13,
                              color: AppColors.mutedSilver.withValues(alpha: .6),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * .025),
                      CustomButton(
                        text: "Sign in",
                        onPressed: login,
                        isLoading: isLoading,
                        borderRadius: Spacing.normalRaduis,
                      ),
                      SizedBox(height: size.height * .03),
                      const OrWidget(),
                      SizedBox(height: size.height * .03),
                      CustomButton(
                        text: "Signup",
                        onPressed: () => context.push(Routes.registerPage),
                        borderRadius: Spacing.normalRaduis,
                        backgroundColor: AppColors.primaryAccent,
                        textColor: AppColors.whiteColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? passwordValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'please enter your password';
    }

    if (val.trim().length < 8) {
      return 'invalid password';
    }

    return null;
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
