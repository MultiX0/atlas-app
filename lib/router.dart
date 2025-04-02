import 'package:atlas_app/features/auth/pages/login_page.dart';
import 'package:atlas_app/features/auth/pages/register_page.dart';
import 'package:atlas_app/features/onboarding/pages/first_page.dart';
import 'package:atlas_app/features/splash/splash_page.dart';

import 'imports.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splashPage,
    routes: [
      // StatefulShellRoute(
      //   branches: [],
      //   navigatorContainerBuilder: (context, state, child) {
      //     return const SizedBox();
      //   },
      // ),
      buildRoute(path: Routes.splashPage, child: const SplashPage()),
      buildRoute(path: Routes.onboardingPage, child: const OnboardingFirstPage()),
      buildRoute(path: Routes.loginPage, child: const LoginPage(), fade: true),
      buildRoute(path: Routes.registerPage, child: const RegisterPage(), fade: true),
    ],
  );
});

GoRoute buildRoute({required String path, required Widget child, bool fade = false}) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) {
      if (!fade) {
        return MaterialPage(child: child);
      }

      return CustomTransitionPage(
        child: child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    },
  );
}
