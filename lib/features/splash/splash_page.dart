// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:atlas_app/imports.dart';
import 'package:no_screenshot/no_screenshot.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  final _noScreenshot = NoScreenshot.instance;

  void enableScreenshot() async {
    await _noScreenshot.screenshotOn();
  }

  @override
  void initState() {
    enableScreenshot();
    log("==============");
    log("on splash");
    log("==============");

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = await ref.read(userState.notifier).initlizeUser();
      if (user != null) {
        context.go(Routes.home);
      } else {
        context.go(Routes.onboardingPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Scaffold(
        body: Stack(
          children: [Center(child: Image.asset('assets/images/logo_atlas.png', width: 200))],
        ),
      ),
    );
  }
}
