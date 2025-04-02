import 'package:atlas_app/imports.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => handleNext());
    super.initState();
  }

  void handleNext() async {
    await Future.wait([
      precacheImage(const AssetAvifImage('assets/images/pattren.avif'), context),
      precacheImage(const AssetImage('assets/images/logo_atlas.png'), context),
      precacheImage(const AssetImage('assets/images/logo_transparent.avif'), context),
    ]);
    await Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      context.pushReplacement(Routes.onboardingPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const LinesPattren(),
          SafeArea(child: Center(child: AvifImage.asset('assets/images/logo_transparent.avif'))),
        ],
      ),
    );
  }
}
