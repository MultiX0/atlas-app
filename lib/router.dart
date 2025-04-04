import 'dart:developer';

import 'package:atlas_app/features/auth/pages/forget_password/confirm_email_page.dart';
import 'package:atlas_app/features/auth/pages/forget_password/email_field_page.dart';
import 'package:atlas_app/features/auth/pages/forget_password/update_password.dart';
import 'package:atlas_app/features/auth/pages/login_page.dart';
import 'package:atlas_app/features/auth/pages/register_page.dart';
import 'package:atlas_app/features/auth/providers/user_state.dart';
import 'package:atlas_app/features/explore/pages/explore_page.dart';
import 'package:atlas_app/features/onboarding/pages/first_page.dart';
import 'package:atlas_app/features/profile/pages/profile_page.dart';
import 'package:atlas_app/features/search/pages/search_page.dart';
import 'package:atlas_app/features/splash/splash_page.dart';
import 'package:atlas_app/nav_bar.dart';

import 'imports.dart';

final navigationShellProvider = Provider<StatefulNavigationShell>((ref) {
  throw UnimplementedError();
});

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splashPage,
    redirect: (context, state) {
      final isUserLoggedIn = ref.watch(userState) != null;
      final loginRoute = state.uri.toString() == Routes.loginPage;
      final registerRoute = state.uri.toString() == Routes.registerPage;
      final forgetPasswordPage =
          state.uri.toString() == Routes.forgotPasswordConfirmEmailPage ||
          state.uri.toString() == Routes.forgotPasswordEmailPage ||
          state.uri.toString() == Routes.updatePasswordPage;

      final firstPageRoute = state.uri.toString() == Routes.onboardingPage;

      if (state.uri.toString() == Routes.splashPage) {
        log("currentlly on the splash page");
        return null;
      }

      if (!isUserLoggedIn) {
        log("user is not logged in");
        log(state.uri.toString());

        if (loginRoute || registerRoute || forgetPasswordPage || firstPageRoute) {
          return null;
        } else {
          return Routes.onboardingPage;
        }
      }

      if (isUserLoggedIn) {
        if (loginRoute || registerRoute || firstPageRoute) {
          return Routes.home;
        }
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        branches: [
          StatefulShellBranch(
            routes: [buildRoute(path: Routes.home, child: const SizedBox(), fade: true)],
          ),
          StatefulShellBranch(
            routes: [buildRoute(path: Routes.aiPage, child: const SizedBox(), fade: true)],
          ),
          StatefulShellBranch(
            routes: [buildRoute(path: Routes.explore, child: const ExplorePage(), fade: true)],
          ),
          StatefulShellBranch(
            routes: [buildRoute(path: Routes.library, child: const SizedBox(), fade: true)],
          ),
          StatefulShellBranch(
            routes: [buildRoute(path: Routes.user, child: const ProfilePage(), fade: true)],
          ),
        ],
        builder: (state, context, shell) {
          return ProviderScope(
            overrides: [navigationShellProvider.overrideWithValue(shell)],
            child: MyNavBar(navigationShell: shell),
          );
        },
      ),
      buildRoute(path: Routes.splashPage, child: const SplashPage()),
      buildRoute(path: Routes.onboardingPage, child: const OnboardingFirstPage()),
      buildRoute(path: Routes.loginPage, child: const LoginPage(), fade: true),
      buildRoute(path: Routes.registerPage, child: const RegisterPage(), fade: true),
      buildRoute(path: Routes.forgotPasswordEmailPage, child: const EmailFieldPage(), fade: true),
      buildRoute(path: Routes.search, child: const SearchPage(), fade: true),

      GoRoute(
        path: "${Routes.updatePasswordPage}/:local",
        pageBuilder: (context, state) {
          final local = state.pathParameters["local"] ?? "f";

          return CustomTransitionPage(
            child: UpdatePassword(localUpdate: local == 't'),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),

      GoRoute(
        path: "${Routes.forgotPasswordConfirmEmailPage}/:${KeyNames.email}",
        pageBuilder: (context, state) {
          final email = state.pathParameters[KeyNames.email] ?? "";
          return CustomTransitionPage(
            child: ConfirmEmailPage(email: email),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
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
