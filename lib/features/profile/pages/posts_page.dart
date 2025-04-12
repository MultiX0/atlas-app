import 'package:atlas_app/core/common/widgets/loader.dart';
import 'package:atlas_app/features/posts/controller/posts_controller.dart';
import 'package:atlas_app/imports.dart';

class ProfilePostsPage extends ConsumerWidget {
  const ProfilePostsPage({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsRef = ref.watch(getUserPostsProvider(user.userId));
    return postsRef.when(
      data: (posts) {
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, i) {
            final post = posts[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkAvifImageProvider(post.user.avatar),
              ),
              title: Text(post.content),
              subtitle: post.parent != null ? Text(post.parent!.content) : null,
            );
          },
        );
      },
      error: (e, _) => Center(child: ErrorWidget(e)),
      loading: () => const Loader(),
    );
  }
}
