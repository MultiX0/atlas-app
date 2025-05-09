// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:atlas_app/imports.dart';
import 'package:atlas_app/main.dart';
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
      await supabaseInit();
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

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void enableScreenshot() async {
    await _noScreenshot.screenshotOn();
  }

  void _handleDeepLink(BuildContext context, Uri uri) {
    // Pass context
    log("Handling deep link: $uri");
    // Check scheme and host if necessary, though path might be enough if using goRouter
    final path = uri.path;
    // Use 'go' to replace the splash page entirely with the deep link destination
    if (path.isNotEmpty && path != '/') {
      // Avoid navigating to "/"
      log("Navigating via context.go to: $path");
      // Ensure the router provider is accessed safely if needed, but context.go is preferred
      context.go(path);
    } else {
      log("Deep link path is empty or root, navigating home.");
      context.go(Routes.home); // Fallback to home if path is invalid/empty
    }
  }

  @override
  void initState() {
    super.initState(); // Call super.initState first
    initAppLinks();
    enableScreenshot();
    log("==============");
    log("on splash");
    log("==============");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      log("Splash: Post frame callback started.");
      try {
        // Initialize user and wait for it to complete
        final user = await ref.read(userState.notifier).initlizeUser();
        log("Splash: User initialization complete. User: ${user?.userId}");

        // Ensure the widget is still mounted before navigating
        if (!mounted) {
          log("Splash: Widget unmounted before navigation.");
          return;
        }

        if (user != null) {
          // User is logged in
          log("Splash: User is logged in.");
          if (_pendingDeepLink != null) {
            log("Splash: Pending deep link found: $_pendingDeepLink");
            // Handle the deep link using context.go
            _handleDeepLink(context, _pendingDeepLink!);
            _pendingDeepLink = null; // Clear the pending link after handling
          } else {
            log("Splash: No pending deep link, navigating home.");
            context.go(Routes.home);
          }
        } else {
          // User is not logged in
          log("Splash: User is not logged in, navigating to onboarding.");
          context.go(Routes.onboardingPage);
        }
      } catch (e) {
        log("Splash: Error during initialization or navigation: $e");
        // Optionally navigate to an error page or onboarding as a fallback
        if (mounted) {
          context.go(Routes.onboardingPage);
        }
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
