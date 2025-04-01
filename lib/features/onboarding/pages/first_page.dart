import 'package:atlas_app/core/common/constants/app_constants.dart';
import 'package:atlas_app/core/common/widgets/custom_button.dart';
import 'package:atlas_app/imports.dart';

// String _getImage(String name) => 'assets/images/$name.jpg';

class OnboardingFirstPage extends ConsumerWidget {
  const OnboardingFirstPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/peakpx.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.scaffoldBackground,
                    Colors.transparent,
                    AppColors.scaffoldBackground,
                  ],
                  stops: [0.0, 0.0, 0.0, 0.65],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 25, size.width * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Image.asset('assets/images/logo_transparent.png', height: 100)),
                    const Spacer(),
                    Text.rich(
                      TextSpan(
                        text: "Welcome to ",
                        children: [
                          TextSpan(text: appName, style: TextStyle(color: AppColors.primary)),
                        ],
                      ),
                      style: TextStyle(fontFamily: accentFont, fontSize: 35),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "A platform for discovering and discussing manga and manhwa. Explore original works from independent creators, engage with the community, and support new talent. Every published piece is available for reading, ensuring a space where stories thrive.",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: size.width * 0.08),
                    CustomButton(
                      text: "Get Started",
                      onPressed: () => context.push(Routes.loginPage),
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
