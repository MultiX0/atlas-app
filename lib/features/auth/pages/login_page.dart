import 'package:atlas_app/core/common/widgets/custom_button.dart';
import 'package:atlas_app/core/common/widgets/custom_text_field.dart';
import 'package:atlas_app/core/common/widgets/line_pattrens_widget.dart';
import 'package:atlas_app/core/common/widgets/or_widget.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        children: [
          LinesPattren(),
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  shrinkWrap: true,
                  children: [
                    Center(child: Image.asset('assets/images/logo_atlas.png', height: 150)),
                    const SizedBox(height: 25),
                    Text(
                      "Sign in to Atlas",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: accentFont, fontSize: 25),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Connect with a community of manga and manhwa enthusiasts. Discover original works, engage in discussions, and support independent creators.",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * .05),
                    CustomTextFormField(
                      hintText: "Enter your email adress",
                      prefixIcon: LucideIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: size.height * .025),
                    CustomTextFormField(
                      hintText: "password",
                      prefixIcon: LucideIcons.lock,
                      obscureText: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Text(
                          "Forgot your password?",
                          style: TextStyle(
                            fontFamily: accentFont,
                            fontSize: 13,
                            color: AppColors.mutedSilver.withValues(alpha: .5),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * .025),
                    CustomButton(
                      text: "Login",
                      onPressed: () {},
                      borderRadius: Spacing.normalRaduis,
                    ),
                    SizedBox(height: size.height * .03),
                    OrWidget(),
                    SizedBox(height: size.height * .03),
                    CustomButton(
                      text: "Signup",
                      onPressed: () {},
                      borderRadius: Spacing.normalRaduis,
                      backgroundColor: AppColors.primaryAccent,
                      textColor: AppColors.whiteColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
