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
  Uri? _pendingDeepLink; // Store the deep link temporarily

  Future<void> initAppLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _pendingDeepLink = initialUri; // Store initial deep link
      }
    } catch (e) {
      log('Error getting initial link: $e');
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _pendingDeepLink = uri; // Store incoming deep link
        }
      },
      onError: (err) {
        log('Error in link stream: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'atlasapp' || uri.host == 'app.atlasapp.app') {
      final path = uri.path;
      ref.read(routerProvider).push(path); // Navigate to the deep link path
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
        // If there's a pending deep link, navigate to it
        if (_pendingDeepLink != null) {
          _handleDeepLink(_pendingDeepLink!);
        } else {
          context.go(Routes.home);
        }
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
