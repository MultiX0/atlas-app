import 'package:atlas_app/core/common/enum/post_like_enum.dart';
import 'package:atlas_app/features/posts/widgets/post_field_widget.dart';
import 'package:atlas_app/features/profile/widgets/post_content_widget.dart';
import 'package:atlas_app/features/profile/widgets/post_header.dart';
import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';

class RepostTreeWidget extends ConsumerWidget {
  const RepostTreeWidget({super.key, required this.postType});

  final PostLikeEnum postType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppColors.mutedSilver.withValues(alpha: .35);

    return ColumnRepostTreeView(
      heigh: 120,
      lineColor: color,
      lineWidth: 1.5,
      children: [
        Consumer(
          builder: (context, ref, _) {
            final post = ref.watch(selectedPostProvider);

            if (post == null) return const SizedBox.shrink();
            final postHasArabic = Bidi.hasAnyRtl(post.content);

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment:
                    postHasArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  PostHeaderWidget(post: post, profileNav: false, postType: postType, repost: true),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: PostContentWidget(post: post, repost: true),
                  ),
                ],
              ),
            );
          },
        ),
        const PostFieldWidget(),
      ],
    );
  }
}
