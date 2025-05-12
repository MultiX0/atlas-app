import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/services/user_vector_service.dart';
import 'package:atlas_app/features/interactions/models/post_interaction_model.dart';
import 'package:atlas_app/features/novels/models/novel_interaction.dart';
import 'package:atlas_app/imports.dart';

class InteractionsDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _novelInteractionsTable => _client.from(TableNames.novel_interactions);

  Future<void> upsertPostInteraction(PostInteractionModel interaction) async {
    try {
      await _client.rpc(
        FunctionNames.upsert_post_interaction,
        params: {'data': interaction.toMap()},
      );
      await updateUserVector(interaction.userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> upsertNovelInteraction(NovelInteraction interaction) async {
    try {
      await _client.rpc(
        FunctionNames.upsert_novel_interaction,
        params: {'data': interaction.toMap()},
      );
      await updateUserVector(interaction.userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<NovelInteraction?> getNovelInteraction(String novelId) async {
    try {
      final data =
          await _novelInteractionsTable.select("*").eq(KeyNames.novel_id, novelId).maybeSingle();
      return data == null ? null : NovelInteraction.fromMap(data);
    } catch (e, trace) {
      log(e.toString(), stackTrace: trace);
      rethrow;
    }
  }
}
