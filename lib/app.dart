// ignore_for_file: use_build_context_synchronously
import 'package:atlas_app/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:atlas_app/core/services/fcm_service.dart';
import 'package:flutter/foundation.dart';

import 'imports.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => handleLoadNotifications());
    super.initState();
  }

  Future<void> handleLoadNotifications() async {
    final fcmService = FCMService();

    Future.microtask(() async {
      if (!kIsWeb) {
        await Future.wait([
          fcmService.initLocalFlutterNotifications(context),
          fcmService.initialize(context, ref: ref),
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
              routerConfig: router,
            ),
          ),
        ),
      ),
    );
  }
}
