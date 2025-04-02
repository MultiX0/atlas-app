import 'dart:developer';

import 'imports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initEnv();
  await _supabaseInit();
  runApp(const ProviderScope(child: App()));
}

Future<void> _initEnv() async {
  await dotenv.load(fileName: '.env');
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
