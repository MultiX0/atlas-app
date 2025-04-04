import 'package:atlas_app/features/auth/controller/auth_controller.dart';
import 'package:atlas_app/features/auth/db/auth_db.dart';
import 'package:atlas_app/features/profile/db/profile_db.dart';
import 'package:atlas_app/imports.dart';

final getUserByIdProvider = FutureProvider.family<UserModel, String>((ref, userId) async {
  final controller = ref.watch(authControllerProvider.notifier);
  return controller.getUserData(userId);
});

class ProfileController extends StateNotifier<bool> {
  final Ref _ref;
  ProfileController({required Ref ref}) : _ref = ref, super(false);

  AuthDb get _authDb => AuthDb();
  ProfileDb get _profileDb => ProfileDb();
}
