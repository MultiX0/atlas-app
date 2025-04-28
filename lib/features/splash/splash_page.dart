// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:atlas_app/imports.dart';
import 'package:atlas_app/router.dart';
import 'package:no_screenshot/no_screenshot.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  final _noScreenshot = NoScreenshot.instance;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Future<void> initAppLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      log('Error getting initial link: $e');
    }

    // Listen for links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        log('Error in link stream: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) async {
    // Handle atlasapp:// and https://app.atlasapp.app
    if (uri.scheme == 'atlasapp' || uri.host == 'app.atlasapp.app') {
      // First, ensure user is initialized
      final user = await ref.read(userState.notifier).initlizeUser();

      // Extract path (e.g., /comicPage/123)
      final path = uri.path;

      // Only navigate if the user is authenticated, otherwise let normal redirect handle it
      if (user != null) {
        ref.read(routerProvider).push(path);
      } else {
        // User isn't authenticated, let the normal flow handle it
        ref.read(routerProvider).go(Routes.onboardingPage);
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void enableScreenshot() async {
    await _noScreenshot.screenshotOn();
  }

  @override
  void initState() {
    initAppLinks();
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
          children: [Center(child: Image.asset('assets/images/logo_at.png', width: 300))],
        ),
      ),
    );
  }
}
