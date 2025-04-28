import 'dart:developer';

import 'package:atlas_app/core/services/fcm_service.dart';
import 'package:atlas_app/core/services/syste_chrome.dart';
import 'package:atlas_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'package:timeago/timeago.dart' as timeago;
import 'imports.dart';

Future<void> main() async {
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  WidgetsFlutterBinding.ensureInitialized();
  await _initEnv();
  await Future.wait([langdetect.initLangDetect(), _supabaseInit(), _firebaseInit()]);
  final fcmService = FCMService();
  await fcmService.initialize();

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

Future<void> _supabaseInit() async {
  try {
    final key = dotenv.env["DB_KEY"];
    final url = dotenv.env["DB_URL"];

    await Supabase.initialize(url: url!, anonKey: key!);
  } catch (e) {
    log(e.toString());
    rethrow;
  }
}
