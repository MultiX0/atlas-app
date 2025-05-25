import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/core/common/utils/encrypt.dart';
import 'package:atlas_app/features/dashs/models/dash_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';

final dashsDBProvider = Provider<DashsDb>((ref) {
  return DashsDb();
});

class DashsDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _dashsView => _client.from(ViewNames.dashs_view);
  // SupabaseQueryBuilder get _dashsTable => _client.from(TableNames.dashs);

  Future<List<DashModel>> getDashs({required int startAt, required int pageSize}) async {
    try {
      final data = await _dashsView
          .select("*")
          .order(KeyNames.created_at, ascending: false)
          .range(startAt, startAt + pageSize - 1);

      return data.map((dash) => DashModel.fromMap(dash)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> postDash({
    required String userId,
    required String token,
    String? content,
    required File file,
  }) async {
    try {
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      var data = dio.FormData.fromMap({
        'files': [
          await dio.MultipartFile.fromFile(
            file.path,
            filename: 'dark-anime-girl-with-red-eyes-desktop-wallpaper.jpg',
            contentType: MediaType('image', 'jpeg'), // Specify content type
          ),
        ],
        'user_id': userId,
        'token': token,
        'content': content,
      });

      final headers = await generateAuthHeaders();
      headers.remove('Content-Type');

      var response = await dio.Dio().request(
        'https://api.atlasapp.app/v1/post-dash',
        options: dio.Options(
          method: 'POST',
          headers: {'Content-Type': 'multipart/form-data', ...headers},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        log('Success: ${json.encode(response.data)}');
      } else {
        log('Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } on dio.DioException catch (e) {
      log('Dio error: ${e.type} - ${e.message}');
      if (e.response != null) {
        log('Response data: ${e.response?.data}');
        log('Response status: ${e.response?.statusCode}');
      }
      rethrow;
    } catch (e) {
      log('General error: ${e.toString()}');
      rethrow;
    }
  }
}
