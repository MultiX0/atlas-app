import 'package:atlas_app/imports.dart';

// String _getImage(String name) => 'assets/images/$name.jpg';

class OnboardingFirstPage extends ConsumerStatefulWidget {
  const OnboardingFirstPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnboardingFirstPageState();
}

class _OnboardingFirstPageState extends ConsumerState<OnboardingFirstPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetAvifImage('assets/images/peakpx.avif'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.scaffoldBackground],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.1, 0.65],
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
                    Center(
                      child: AvifImage.asset('assets/images/logo_transparent.avif', height: 100),
                    ),
                    const Spacer(),
                    const Text.rich(
                      TextSpan(
                        text: "Welcome to ",
                        children: [
                          TextSpan(text: appName, style: TextStyle(color: AppColors.primary)),
                        ],
                      ),
                      style: TextStyle(fontFamily: accentFont, fontSize: 35),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "A platform for discovering and discussing manga and manhwa. Explore original works from independent creators, engage with the community, and support new talent. Every published piece is available for reading, ensuring a space where stories thrive.",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: size.width * 0.08),
                    CustomButton(
                      text: "Get Started",
                      onPressed: () {
                        context.pushReplacement(Routes.loginPage);
                      },
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
