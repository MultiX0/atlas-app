import 'package:atlas_app/core/common/enum/hashtag_enum.dart';
import 'package:atlas_app/features/hashtags/widgets/hashtag_filter_widget.dart';
import 'package:atlas_app/features/posts/models/post_model.dart';
import 'package:atlas_app/features/profile/widgets/post_widget.dart';
import 'package:atlas_app/imports.dart';

class HashtagsBody extends StatelessWidget {
  const HashtagsBody({
    super.key,
    required this.posts,
    required this.loadingMore,
    required this.updateFilter,
    required this.currentFilter,
  });

  final List<PostModel> posts;
  final bool loadingMore;
  final Function(HashtagFilter) updateFilter;
  final HashtagFilter currentFilter;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: true,
      itemCount:
          posts.isEmpty
              ? 2 // Top widget + empty state
              : 1 + posts.length + (loadingMore ? 1 : 0), // Top widget + posts + optional loader
      itemBuilder: (context, i) {
        // Top widget at index 0
        if (i == 0) {
          return HashtagFilterWidget(currentFilter: currentFilter, updateFilter: updateFilter);
        }

        // Empty state (after top widget)
        if (posts.isEmpty && i == 1) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/no_data_cry_.gif', height: 130),
                  const SizedBox(height: 15),
                  const Text(
                    "لايوجد أي مناشير في هذا الهاشتاق",
                    style: TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        }

        // Loader at the end
        if (loadingMore && i == 1 + posts.length) {
          return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: Loader()));
        }

        // Posts (from i == 1 to posts.length)
        final post = posts[i - 1];
        return PostWidget(
          key: ValueKey(post.postId),
          post: post,
          onComment: () {},
          onLike: (_) async => true,
          onRepost: () {},
          onShare: () {},
        );
      },
    );
  }
}
