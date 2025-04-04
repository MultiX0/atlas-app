// ignore_for_file: use_build_context_synchronously

import 'package:atlas_app/core/providers/supabase_provider.dart';
import 'package:atlas_app/core/services/syste_chrome.dart';
import 'package:atlas_app/features/auth/providers/user_state.dart';
import 'package:atlas_app/router.dart';

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
  }

  void handleUserAuth() async {
    final client = ref.read(supabaseProvider);
    client.auth.onAuthStateChange.listen((changes) {
      if (changes.session != null && changes.session?.user != null) {
        ref.read(userState);
      } else {
        ref.read(userState.notifier).clearState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return ToastificationWrapper(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkModeAppTheme,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        routerDelegate: router.routerDelegate,
      ),
    );
  }
}
