import 'dart:developer';

import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/services/user_vector_service.dart';
import 'package:atlas_app/features/interactions/models/post_interaction_model.dart';
import 'package:atlas_app/imports.dart';

class InteractionsDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _postInteractionsTable => _client.from(TableNames.post_interactions);

  Future<void> upsertPostInteraction(PostInteractionModel interaction) async {
    try {
      await _postInteractionsTable.upsert(interaction.toMap(), onConflict: KeyNames.id);
      await updateUserVector(interaction.userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
