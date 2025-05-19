import 'dart:developer';

import 'package:atlas_app/features/post_comments/pages/post_comments_page.dart';
import 'package:atlas_app/features/posts/pages/post_page.dart';

import 'imports.dart';

final navigationShellProvider = Provider<StatefulNavigationShell>((ref) {
  throw UnimplementedError();
});

final rootNavigationKey = Provider<GlobalKey<NavigatorState>>((ref) => GlobalKey<NavigatorState>());

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ValueNotifier<bool>(ref.read(isLoggedProvider));

  ref.listen<bool>(isLoggedProvider, (_, isLoggedIn) {
    authState.value = isLoggedIn;
  });

  String? authRedirect(context, state) {
    final user = ref.read(userState.select((s) => s.user));
    if (user != null) {
      return null;
    } else {
      return Routes.splashPage;
    }
  }

  final _key = ref.read(rootNavigationKey);

  return GoRouter(
    navigatorKey: _key,
    initialLocation: Routes.splashPage,
    refreshListenable: authState,
    redirect: (context, state) {
      final splashRoute = state.uri.toString() == Routes.splashPage;
      if (splashRoute) {
        return null; // Always allow splash page
      }

      final isUserLoggedIn = authState.value;
      final loginRoute = state.uri.toString() == Routes.loginPage;
      final registerRoute = state.uri.toString() == Routes.registerPage;
      final forgetPasswordPage = [
        Routes.forgotPasswordConfirmEmailPage,
        Routes.forgotPasswordEmailPage,
        Routes.updatePasswordPage,
        Routes.forgotPassword,
      ].contains(state.uri.toString());
      final firstPageRoute = state.uri.toString() == Routes.onboardingPage;

      // Allow deep links to proceed if user is logged in
      if (isUserLoggedIn) {
        if (loginRoute || registerRoute || firstPageRoute) {
          return Routes.home; // Redirect to home if trying to access login/register/onboarding
        }
        return null; // Allow all other routes (including deep links)
      }

      // If not logged in, redirect to onboarding unless on allowed routes
      if (!isUserLoggedIn) {
        log("user is not logged in");
        log(state.uri.toString());
        if (loginRoute || registerRoute || forgetPasswordPage || firstPageRoute) {
          return null;
        }
        return Routes.onboardingPage;
      }

      return null;
    },

    routes: [
      StatefulShellRoute.indexedStack(
        branches: [
          StatefulShellBranch(
            routes: [buildRoute(path: Routes.home, child: const MainFeedPage(), fade: true)],
          ),
          StatefulShellBranch(
            routes: [buildRoute(path: Routes.aiPage, child: const AssistantChatPage(), fade: true)],
          ),
          StatefulShellBranch(
            routes: [buildRoute(path: Routes.explore, child: const ExplorePage(), fade: true)],
          ),
          StatefulShellBranch(
            routes: [buildRoute(path: Routes.makePostPage, child: const SizedBox(), fade: true)],
          ),
          StatefulShellBranch(
            routes: [buildRoute(path: Routes.scrolls, child: const ScrollsPage(), fade: true)],
          ),
          StatefulShellBranch(
            routes: [buildRoute(path: Routes.library, child: const LibraryPage(), fade: true)],
          ),
          StatefulShellBranch(
            routes: [
              buildRoute(path: Routes.profile, child: const ProfilePage(userId: ''), fade: true),
            ],
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
      buildRoute(path: Routes.manhwaPage, child: const ManhwaPage(fromSearch: true), fade: true),
      buildRoute(path: Routes.addNovelChapterPage, child: const AddChapterPage(), fade: true),
      buildRoute(path: Routes.novelChapterDrafts, child: const ChapterDraftsPage(), fade: true),
      buildRoute(path: Routes.novelReadChapter, child: const ChapterReadingPage(), fade: true),
      buildRoute(path: Routes.chapterCommentsPage, child: const ChapterCommentsPage(), fade: true),
      buildRoute(path: Routes.editProfile, child: const EditProfileScreen(), fade: true),
      buildRoute(path: Routes.addNovelPage, child: const AddNovelPage(edit: false), fade: true),

      GoRoute(
        path: Routes.forgotPassword,
        name: Routes.forgotPassword,
        pageBuilder: (context, state) {
          final email = ((state.extra as Map<String, dynamic>)["email"] ?? "").toString().trim();

          return CustomTransitionPage(
            child: ForgotPasswordPage(email: email),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),

      GoRoute(
        path: "${Routes.addComicReview}/:update/:type",
        pageBuilder: (context, state) {
          final update = state.pathParameters["update"] ?? "f";
          final type = reviewsEnumFromString(state.pathParameters['type'] ?? "comic");

          return CustomTransitionPage(
            child: AddComicReview(update: update == 't', reviewType: type),
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
        path: "${Routes.addNovelPage}/:edit",
        pageBuilder: (context, state) {
          final local = state.pathParameters["edit"] ?? "f";

          return CustomTransitionPage(
            child: AddNovelPage(edit: local == 't'),
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
        parentNavigatorKey: _key,
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
          final defaultText =
              ref.read(selectedPostProvider)?.content ?? state.pathParameters['defaultText'] ?? "";

          return CustomTransitionPage(
            child: MakePostPage(
              postType: type,
              defaultText: defaultText.isNotEmpty ? defaultText : '',
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
        parentNavigatorKey: _key,
        path: "${Routes.novelPage}/:id",
        redirect: authRedirect,
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

      GoRoute(
        parentNavigatorKey: _key,
        path: "${Routes.postPage}/:id",
        redirect: authRedirect,
        pageBuilder: (context, state) {
          final id = state.pathParameters["id"] ?? "";

          return CustomTransitionPage(
            child: PostPage(postId: id),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),

      GoRoute(
        parentNavigatorKey: _key,
        path: "${Routes.postComments}/:id",
        redirect: authRedirect,
        pageBuilder: (context, state) {
          final id = state.pathParameters["id"] ?? "";
          return CustomTransitionPage(
            child: PostCommentsPage(postId: id, withAppBar: true),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),

      GoRoute(
        parentNavigatorKey: _key,
        path: "${Routes.comicPage}/:id",
        redirect: authRedirect,

        pageBuilder: (context, state) {
          final id = state.pathParameters["id"] ?? "";

          return CustomTransitionPage(
            child: ManhwaLoader(comicId: id),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),

      GoRoute(
        parentNavigatorKey: _key,
        path: "${Routes.user}/:id",
        redirect: authRedirect,

        pageBuilder: (context, state) {
          final id = state.pathParameters["id"] ?? "";

          return CustomTransitionPage(
            child: ProfilePage(userId: id),
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
