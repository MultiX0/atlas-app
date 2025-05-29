// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/core/common/utils/encrypt.dart';
import 'package:atlas_app/features/dashs/models/dash_interaction_model.dart';
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

  Future<List<String>> fetchMainFeedDashsRecommendations({
    required int page,
    required String userId,
  }) async {
    try {
      final url = '${appAPI}dashs-recommendation?page=$page&user_id=$userId';
      final headers = await generateAuthHeaders();
      final options = dio.Options(
        headers: headers,
        sendTimeout: const Duration(microseconds: 2),
        receiveTimeout: const Duration(seconds: 2),
      );
      final res = await dio.Dio().get(url, options: options);
      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! <= 299) {
        if (res.data == null) {
          log('Error: Response data is null');
          return [];
        }

        final data = res.data;
        log("data: $data");

        if ((data is List && data.isEmpty) || data.toString().trim() == '[]') {
          return [];
        }

        dynamic parsedData;
        if (data is String) {
          parsedData = jsonDecode(data);
        } else {
          parsedData = data;
        }

        if (parsedData is List) {
          return List<String>.from(
            parsedData.where((item) => item != null).map((item) => item.toString()),
          );
        } else {
          log('Error: Expected a List but got ${parsedData.runtimeType}');
          return [];
        }
      }
      return [];
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<List<DashModel>> getDashs({
    required String userId,
    required int currentPage,
    required int startAt,
    required int pageSize,
  }) async {
    try {
      final ids = await fetchMainFeedDashsRecommendations(userId: userId, page: currentPage);
      dynamic query;

      if (ids.isEmpty) {
        log("ids from api is empty switching from the database");
        query = _dashsView
            .select("*")
            .order(KeyNames.created_at, ascending: false)
            .range(startAt, (pageSize + startAt - 1));
      } else {
        query = _dashsView.select("*").inFilter(KeyNames.id, ids);
      }

      List<Map<String, dynamic>> dashData = await query;
      final idIndexMap = {for (var i = 0; i < ids.length; i++) ids[i]: i};
      dashData.sort(
        (a, b) => (idIndexMap[a[KeyNames.id]] ?? ids.length).compareTo(
          idIndexMap[b[KeyNames.id]] ?? ids.length,
        ),
      );

      return dashData.map((dash) => DashModel.fromMap(dash)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<DashModel> getDashById(String id) async {
    try {
      final data = await _dashsView.select("*").eq(KeyNames.id, id).maybeSingle();
      if (data == null) throw 'no dash with this id: $id';
      // log(data.toString());

      return DashModel.fromMap(data);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> upsertDashInteraction(DashInteractionModel interaction) async {
    try {
      await _client.rpc(
        FunctionNames.upsert_dash_interaction,
        params: {'data': interaction.toMap()},
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updateDashsEmbedding(String userId) async {
    try {
      final url = '${appAPI}update-dashs-embedding?user_id=$userId';
      final headers = await generateAuthHeaders();
      final options = dio.Options(
        headers: headers,
        sendTimeout: const Duration(microseconds: 2),
        receiveTimeout: const Duration(seconds: 2),
      );

      final res = await dio.Dio().post(url, options: options);
      if (res.statusCode! >= 200 && res.statusCode! <= 299) {
        return;
      }

      throw 'updateDashsEmbedding failed';
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<String>> fetchRecommendationDashBasedOnId({
    required String dashId,
    required int page,
    required String userId,
  }) async {
    try {
      final url = '${appAPI}dash-recommendation?dash_id=$dashId&page=$page&user_id=$userId';
      final headers = await generateAuthHeaders();
      final options = dio.Options(
        headers: headers,
        sendTimeout: const Duration(microseconds: 2),
        receiveTimeout: const Duration(seconds: 2),
      );
      final res = await dio.Dio().get(url, options: options);
      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! <= 299) {
        if (res.data == null) {
          log('Error: Response data is null');
          return [];
        }

        final data = res.data;

        if (data is List) {
          return List<String>.from(
            data.where((item) => item != null).map((item) => item.toString()),
          );
        } else {
          log('Error: Expected a List but got ${data.runtimeType}');
          return [];
        }
      }
      return [];
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<List<DashModel>> getRecommendationsBasedOnDash({
    required String userId,
    required int page,
    required String dashId,
  }) async {
    try {
      final ids = await fetchRecommendationDashBasedOnId(
        userId: userId,
        page: page,
        dashId: dashId,
      );

      if (ids.isEmpty) return [];

      var query = _dashsView.select("*");

      query = query.inFilter(KeyNames.id, ids);

      final dashData = await query;
      final idIndexMap = {for (var i = 0; i < ids.length; i++) ids[i]: i};
      dashData.sort(
        (a, b) => (idIndexMap[a[KeyNames.id]] ?? ids.length).compareTo(
          idIndexMap[b[KeyNames.id]] ?? ids.length,
        ),
      );

      return dashData.map((d) => DashModel.fromMap(d)).toList();
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

      log("image path: ${file.path}");

      var data = dio.FormData.fromMap({
        // Change 'files' to 'image'
        'files': await dio.MultipartFile.fromFile(
          file.path,
          contentType: MediaType('image', 'webp'), // Specify content type
        ),
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
          headers: {...headers, 'Content-Type': 'multipart/form-data'},
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
