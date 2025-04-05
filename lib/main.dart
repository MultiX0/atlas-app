import 'dart:developer';

import 'package:atlas_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'imports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initEnv();
  await _supabaseInit();
  await _firebaseInit();
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
