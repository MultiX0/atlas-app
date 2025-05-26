// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/file_compressor.dart';
import 'package:atlas_app/features/dashs/db/dashs_db.dart';
import 'package:atlas_app/features/dashs/models/dash_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:loader_overlay/loader_overlay.dart';

final dashsControllerProvider = StateNotifierProvider<DashsController, bool>((ref) {
  return DashsController(ref: ref);
});

final getDashByIdProvider = FutureProvider.family<DashModel, String>((ref, id) async {
  final controller = ref.watch(dashsControllerProvider.notifier);
  return controller.getDashById(id);
});

class DashsController extends StateNotifier<bool> {
  final Ref _ref;
  DashsController({required Ref ref}) : _ref = ref, super(false);
  DashsDb get _db => _ref.read(dashsDBProvider);

  Future<void> postDash({
    String? content,
    required File image,
    required BuildContext context,
  }) async {
    try {
      context.loaderOverlay.show();
      final compresedFile = await compressFile(image, 60);
      var token = Supabase.instance.client.auth.currentSession?.accessToken;
      final me = _ref.read(userState.select((s) => s.user!));

      if (token == null) {
        await Supabase.instance.client.auth.refreshSession();
        token = Supabase.instance.client.auth.currentSession!.accessToken;
      }

      await _db.postDash(file: compresedFile, userId: me.userId, token: token, content: content);
      context.loaderOverlay.hide();
      CustomToast.success("تم نشر ومضة جديدة بنجاح");
      context.pop();
    } catch (e) {
      context.loaderOverlay.hide();
      log(e.toString());
      CustomToast.error(e.toString());
      rethrow;
    }
  }

  Future<DashModel> getDashById(String id) async {
    try {
      return await _db.getDashById(id);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
