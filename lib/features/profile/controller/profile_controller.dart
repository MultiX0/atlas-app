import 'package:atlas_app/features/auth/controller/auth_controller.dart';
import 'package:atlas_app/features/auth/db/auth_db.dart';
import 'package:atlas_app/features/profile/db/profile_db.dart';
import 'package:atlas_app/imports.dart';

final getUserByIdProvider = FutureProvider.family<UserModel, String>((ref, userId) async {
  final controller = ref.watch(authControllerProvider.notifier);
  return controller.getUserData(userId);
});

class ProfileController extends StateNotifier<bool> {
  // ignore: unused_field
  final Ref _ref;
  ProfileController({required Ref ref}) : _ref = ref, super(false);

  // ignore: unused_element
  AuthDb get _authDb => AuthDb();
  // ignore: unused_element
  ProfileDb get _profileDb => ProfileDb();
}
