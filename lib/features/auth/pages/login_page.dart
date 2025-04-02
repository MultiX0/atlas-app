import 'package:atlas_app/core/common/widgets/line_pattrens_widget.dart';
import 'package:atlas_app/core/common/widgets/or_widget.dart';
import 'package:atlas_app/imports.dart';

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
          const LinesPattren(),
          Positioned.fill(
            child: SafeArea(
              child: Center(
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
                      hintText: "Enter your email adress",
                      prefixIcon: LucideIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: size.height * .025),
                    CustomTextFormField(
                      controller: _passwordController,
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
                      text: "Sign in",
                      onPressed: () {},
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
        ],
      ),
    );
  }
}
