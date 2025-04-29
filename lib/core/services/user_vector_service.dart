import 'dart:developer';

import 'package:atlas_app/core/common/constants/app_constants.dart';
import 'package:atlas_app/core/common/utils/encrypt.dart';
import 'package:dio/dio.dart';

Future<void> updateUserVector(String userId) async {
  try {
    final _dio = Dio();
    final authHeaders = await generateAuthHeaders();
    await _dio.post(
      '${appAPI}update-user-embedding?user_id=$userId',
      options: Options(headers: authHeaders),
    );
  } catch (e) {
    log(e.toString());
    rethrow;
  }
}
