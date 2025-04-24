// ignore_for_file: use_build_context_synchronously
import 'package:atlas_app/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'imports.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(routerProvider);
    return RepaintBoundary(
      child: Portal(
        child: GlobalLoaderOverlay(
          overlayColor: Colors.black54,
          overlayWidgetBuilder: (_) {
            return const Center(child: Loader());
          },
          child: ToastificationWrapper(
            child: MaterialApp.router(
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                FlutterQuillLocalizations.delegate,
              ],
              debugShowCheckedModeBanner: false,
              theme: AppTheme.darkModeAppTheme,
              // routeInformationParser: router.routeInformationParser,
              // routeInformationProvider: router.routeInformationProvider,
              // routerDelegate: router.routerDelegate,
              routerConfig: router,
            ),
          ),
        ),
      ),
    );
  }
}
