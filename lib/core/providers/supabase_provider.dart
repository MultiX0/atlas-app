import 'package:atlas_app/imports.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final isUserLoggedInProvider = Provider<bool>((ref) {
  return false;
});
