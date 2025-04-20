import 'dart:developer';

import 'package:atlas_app/features/auth/pages/forget_password/confirm_email_page.dart';
import 'package:atlas_app/features/auth/pages/forget_password/email_field_page.dart';
import 'package:atlas_app/features/auth/pages/forget_password/update_password.dart';
import 'package:atlas_app/features/auth/pages/login_page.dart';
import 'package:atlas_app/features/auth/pages/register_page.dart';
import 'package:atlas_app/features/comics/pages/manhwa_page.dart';
import 'package:atlas_app/features/explore/pages/explore_page.dart';
import 'package:atlas_app/features/hashtags/pages/hashtag_page.dart';
import 'package:atlas_app/features/library/pages/add_novel_page.dart';
import 'package:atlas_app/features/library/pages/library_page.dart';
import 'package:atlas_app/features/novels/widgets/novel_loader.dart';
import 'package:atlas_app/features/onboarding/pages/first_page.dart';
import 'package:atlas_app/features/posts/pages/make_post_page.dart';
import 'package:atlas_app/features/posts/providers/providers.dart';
import 'package:atlas_app/features/profile/pages/profile_page.dart';
import 'package:atlas_app/features/reviews/pages/add_comic_review.dart';
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
      final splashRoute = state.uri.toString() == Routes.splashPage;
      if (splashRoute) {
        return null;
      }

      final userStateValue = ref.watch(userState.select((state) => state.user));
      // log("user state is $userStateValue");
      final isUserLoggedIn = userStateValue != null;
      final loginRoute = state.uri.toString() == Routes.loginPage;
      final registerRoute = state.uri.toString() == Routes.registerPage;
      final forgetPasswordPage =
          state.uri.toString() == Routes.forgotPasswordConfirmEmailPage ||
          state.uri.toString() == Routes.forgotPasswordEmailPage ||
          state.uri.toString() == Routes.updatePasswordPage;
      final firstPageRoute = state.uri.toString() == Routes.onboardingPage;

      if (!isUserLoggedIn) {
        log("user is not logged in");
        log(state.uri.toString());
        if (loginRoute || registerRoute || forgetPasswordPage || firstPageRoute) {
          return null;
        } else {
          return Routes.onboardingPage;
        }
      }

      if (isUserLoggedIn && (loginRoute || registerRoute || firstPageRoute)) {
        return Routes.home;
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
            routes: [buildRoute(path: Routes.makePostPage, child: const SizedBox(), fade: true)],
          ),
          StatefulShellBranch(
            routes: [buildRoute(path: Routes.scrolls, child: const SizedBox(), fade: true)],
          ),
          StatefulShellBranch(
            routes: [buildRoute(path: Routes.library, child: const LibraryPage(), fade: true)],
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
      buildRoute(path: Routes.manhwaPage, child: const ManhwaPage(), fade: true),
      buildRoute(path: Routes.addNovelPost, child: const AddNovelPage(), fade: true),
      GoRoute(
        path: "${Routes.addComicReview}/:update",
        pageBuilder: (context, state) {
          final update = state.pathParameters["update"] ?? "f";

          return CustomTransitionPage(
            child: AddComicReview(update: update == 't'),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),

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
      GoRoute(
        path: "${Routes.hashtagsPage}/:${KeyNames.hashtag}",
        pageBuilder: (context, state) {
          final hashtag = state.pathParameters[KeyNames.hashtag] ?? "";
          return CustomTransitionPage(
            child: HashtagPage(hashtag: hashtag),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: "${Routes.makePostPage}/:type/:defaultText",
        pageBuilder: (context, state) {
          final typeString = state.pathParameters["type"];
          final type = stringToPostType(typeString ?? "normal");
          final defaultText = ref.read(selectedPostProvider)!.content;

          return CustomTransitionPage(
            child: MakePostPage(
              postType: type,
              defaultText: defaultText.isNotEmpty ? '$defaultText\n' : '',
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: "${Routes.makePostPage}/:type",
        pageBuilder: (context, state) {
          final typeString = state.pathParameters["type"];
          final type = stringToPostType(typeString ?? "normal");

          return CustomTransitionPage(
            child: MakePostPage(postType: type),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: "${Routes.novelPage}/:id",
        pageBuilder: (context, state) {
          final id = state.pathParameters["id"] ?? "";

          return CustomTransitionPage(
            child: NovelLoader(novelId: id),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      // Catch-all for invalid links
      GoRoute(
        path: '/:path(.*)',
        builder:
            (context, state) => Scaffold(body: Center(child: Text('Invalid Link: ${state.path}'))),
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
