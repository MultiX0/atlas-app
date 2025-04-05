// ignore_for_file: use_build_context_synchronously

import 'package:atlas_app/core/services/syste_chrome.dart';
import 'package:atlas_app/features/auth/providers/user_state.dart';
import 'package:atlas_app/router.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'imports.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    editChromeSystem();
    WidgetsBinding.instance.addPostFrameCallback((_) => initAuth());
  }

  Future<void> initAuth() async {
    await ref.read(userState.notifier).initlizeUser();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return GlobalLoaderOverlay(
      child: ToastificationWrapper(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkModeAppTheme,
          routeInformationParser: router.routeInformationParser,
          routeInformationProvider: router.routeInformationProvider,
          routerDelegate: router.routerDelegate,
        ),
      ),
    );
  }
}
