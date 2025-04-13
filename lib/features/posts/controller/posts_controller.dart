import 'dart:developer';

import 'package:atlas_app/features/posts/db/posts_db.dart';
import 'package:atlas_app/features/posts/models/post_model.dart';
import 'package:atlas_app/imports.dart';

final postsControllerProvider = StateNotifierProvider<PostsController, bool>((ref) {
  return PostsController(ref: ref);
});

final getUserPostsProvider = FutureProvider.family<List<PostModel>, String>((ref, userId) async {
  final controller = ref.watch(postsControllerProvider.notifier);
  return await controller.getUserPosts(userId);
});

class PostsController extends StateNotifier<bool> {
  // ignore: unused_field
  final Ref _ref;
  PostsController({required Ref ref}) : _ref = ref, super(false);

  PostsDb get db => PostsDb();

  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      return await db.getUserPosts(userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> slashMentionSearch(String query) async {
    try {
      return await db.slashMentionSearch(query);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
