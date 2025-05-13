import 'package:atlas_app/imports.dart';

class PostState extends StateNotifier<PostModel?> {
  PostState() : super(null);

  void updatePost(PostModel post) {
    state = post;
  }
}

final postStateProvider = StateNotifierProvider<PostState, PostModel?>((ref) {
  return PostState();
});
