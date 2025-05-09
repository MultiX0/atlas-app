import 'dart:developer';

import 'package:atlas_app/core/services/secure_storage_service.dart';
import 'package:atlas_app/core/services/syste_chrome.dart';
import 'package:atlas_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'package:timeago/timeago.dart' as timeago;
import 'imports.dart';

Future<void> main() async {
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  WidgetsFlutterBinding.ensureInitialized();
  await _initEnv();
  await Future.wait([langdetect.initLangDetect(), supabaseInit(), _firebaseInit()]);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  editChromeSystem();

  runApp(const ProviderScope(child: App()));
}

Future<void> _initEnv() async {
  await dotenv.load(fileName: '.env');
}

Future<void> _firebaseInit() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    log(e.toString());
    rethrow;
  }
}

Future<void> supabaseInit() async {
  try {
    await _initEnv();
    final key = dotenv.env["DB_KEY"];
    final url = dotenv.env["DB_URL"];

    final secureStorage = SecureLocalStorage();
    await secureStorage.initialize();

    await Supabase.initialize(
      url: url!,
      anonKey: key!,
      debug: kDebugMode,
      authOptions: FlutterAuthClientOptions(
        localStorage: secureStorage,
        detectSessionInUri: true,
        autoRefreshToken: true,
      ),
    );
  } catch (e) {
    log(e.toString());
    rethrow;
  }
}
