// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/image_to_avif_convert.dart';
import 'package:atlas_app/core/common/utils/upload_storage.dart';
import 'package:atlas_app/features/auth/controller/auth_controller.dart';
import 'package:atlas_app/features/auth/db/auth_db.dart';
import 'package:atlas_app/features/profile/db/profile_db.dart';
import 'package:atlas_app/features/profile/provider/providers.dart';
import 'package:atlas_app/imports.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:uuid/uuid.dart';

final getUserByIdProvider = FutureProvider.family<UserModel, String>((ref, userId) async {
  final controller = ref.watch(authControllerProvider.notifier);

  final user = await controller.getUserData(userId);
  ref.read(selectedUserProvider.notifier).state = user;
  return user;
});

final searchUsersProvider = FutureProvider.family<List<UserModel>, String>((ref, query) async {
  final controller = ref.watch(profileControllerProvider.notifier);

  return await controller.profileSearch(query);
});

final profileControllerProvider = StateNotifierProvider<ProfileController, bool>((ref) {
  return ProfileController(ref: ref);
});

class ProfileController extends StateNotifier<bool> {
  // ignore: unused_field
  final Ref _ref;
  ProfileController({required Ref ref}) : _ref = ref, super(false);

  final uuid = const Uuid();

  // ignore: unused_element
  AuthDb get _authDb => AuthDb();
  // ignore: unused_element
  ProfileDb get _profileDb => ProfileDb();

  Future<List<Map<String, dynamic>>> fetchUsersForMention(String query) async {
    try {
      return await _profileDb.fetchUsersForMention(query);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<UserModel>> profileSearch(String query) async {
    try {
      return await _profileDb.profileSearch(query);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String userName,
    required String? bio,
    required File? avatar,
    required File? banner,
    required String avatarUrl,
    required String? bannerUrl,
    required BuildContext context,
  }) async {
    try {
      final me = _ref.read(userState).user!;

      if (fullName == me.fullName &&
          userName == me.username &&
          bio == me.bio &&
          avatar == null &&
          banner == null) {
        context.pop();
        return;
      }
      state = true;
      context.loaderOverlay.show();
      if (userName != me.username) {
        final isTaken = await _authDb.isUsernameTaken(userName.trim().toLowerCase());
        if (isTaken) {
          CustomToast.error("اسم المستخدم اللذي أدخلته محجوز بالفعل");
          context.loaderOverlay.hide();
          return;
        }
      }

      String avatarLink;
      String? bannerLink;
      final data = await Future.wait<dynamic>([
        if (avatar != null) uploadImage(avatar, me.userId, avatar: true),
        if (banner != null) uploadImage(banner, me.userId, avatar: false),
      ]);

      if (data.isNotEmpty) {
        avatarLink = data[0] ?? avatarUrl;
        bannerLink = data[1] ?? bannerUrl;
      } else {
        avatarLink = avatarUrl;
        bannerLink = bannerUrl;
      }

      final updatedUser = me.copyWith(
        username: userName,
        avatar: avatarLink,
        banner: bannerLink,
        fullName: fullName,
        bio: bio,
      );

      await _profileDb.updateProfile(updatedUser);
      _ref.read(userState.notifier).updateState(updatedUser);
      context.loaderOverlay.hide();
      state = false;
      context.pop();
      CustomToast.success("تم تحديث معلومات الملف الشخصي بنجاح");
    } catch (e) {
      context.loaderOverlay.hide();
      state = false;
      CustomToast.error(errorMsg);
      log(e.toString());
      rethrow;
    }
  }

  Future<String> uploadImage(File image, String userId, {required bool avatar}) async {
    try {
      String link;
      final avifImage = await AvifConverter.convertToAvif(image, quality: 80);
      if (avifImage != null) {
        link = await UploadStorage.uploadImages(
          image: avifImage,
          path:
              '/users/$userId/${avatar ? 'avatar-${uuid.v4()}.avif' : 'banner-${uuid.v4()}.avif'}',
          quiality: 80,
        );
      } else {
        link = await UploadStorage.uploadImages(
          image: image,
          path: '/users/$userId/${avatar ? 'avatar-${uuid.v4()}.png' : 'banner-${uuid.v4()}.png'}',
          quiality: 80,
        );
      }

      return link;
    } catch (e, trace) {
      log(e.toString(), stackTrace: trace);
      rethrow;
    }
  }

  Future<void> handleUserFollow(String targetId) async {
    final oldUser = _ref.read(selectedUserProvider);
    final me = _ref.read(userState.select((s) => s.user!));
    try {
      _ref.read(selectedUserProvider.notifier).state = oldUser?.copyWith(
        followed: !(oldUser.followed ?? false),
        followers_count:
            (oldUser.followed ?? false) ? oldUser.followers_count - 1 : oldUser.followers_count + 1,
      );

      _ref
          .read(userState.notifier)
          .updateState(
            me.copyWith(
              following_count:
                  (oldUser?.followed ?? false) ? me.following_count - 1 : me.following_count + 1,
            ),
          );

      await _profileDb.toggleFollow(targetId);
    } catch (e) {
      _ref.read(selectedUserProvider.notifier).state = oldUser;
      _ref.read(userState.notifier).updateState(me);

      CustomToast.error(errorMsg);
      log(e.toString());
      rethrow;
    }
  }
}
