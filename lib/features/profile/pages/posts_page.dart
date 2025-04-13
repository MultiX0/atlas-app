import 'package:atlas_app/features/posts/controller/posts_controller.dart';
import 'package:atlas_app/features/profile/widgets/post_widget.dart';
import 'package:atlas_app/imports.dart';

class ProfilePostsPage extends ConsumerWidget {
  const ProfilePostsPage({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsRef = ref.watch(getUserPostsProvider(user.userId));
    return postsRef.when(
      data: (posts) {
        return RepaintBoundary(
          child: CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                sliver: SliverList.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, i) {
                    final post = posts[i];
                    return PostWidget(
                      post: post,
                      onComment: () {},
                      onLike: (_) async => true,
                      onRepost: () {},
                      onShare: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      error: (e, _) => Center(child: ErrorWidget(e)),
      loading: () => const Loader(),
    );
  }
}
