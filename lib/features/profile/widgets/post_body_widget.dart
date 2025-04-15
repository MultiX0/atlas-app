import 'dart:developer';
import 'package:atlas_app/core/common/widgets/image_view_controller.dart';
import 'package:atlas_app/core/common/widgets/rich_text_view/models.dart';
import 'package:atlas_app/core/common/widgets/rich_text_view/text_view.dart';
import 'package:atlas_app/core/common/widgets/slash_parser.dart';
import 'package:atlas_app/features/posts/models/post_model.dart';
import 'package:atlas_app/features/profile/widgets/interactions_bar.dart';
import 'package:atlas_app/imports.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';

class PostBodyWidget extends StatelessWidget {
  const PostBodyWidget({
    super.key,
    required this.post,
    required this.onComment,
    required this.onLike,
    required this.onRepost,
    required this.onShare,
    required this.hasArabic,
    this.hashtag,
  });

  final PostModel post;
  final bool hasArabic;
  final Future<bool?> Function(bool)? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;
  final String? hashtag;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: hasArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          PostContentWidget(post: post),
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            ViewImagesController(
              images: post.images.map((image) => CachedNetworkAvifImageProvider(image)).toList(),
            ),
          ],
          const SizedBox(height: 12),
          InteractionBar(
            isShared: post.shared_by_me,
            likes: post.likeCount,
            comments: post.commentsCount,
            reposts: post.repostedCount,
            shares: post.shares_count,
            isLiked: post.userLiked,
            onLike: onLike,
            onComment: onComment,
            onRepost: onRepost,
            onShare: onShare,
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}

class PostContentWidget extends StatelessWidget {
  final String? hashtag;
  const PostContentWidget({super.key, required this.post, this.hashtag});

  final PostModel post;
  bool get hasArabic => Bidi.hasAnyRtl(post.content);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: RepaintBoundary(
        child: RichTextView(
          key: ValueKey(post.postId),
          textDirection: hasArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          text: post.content,
          maxLines: 20,
          truncate: true,
          style: TextStyle(fontWeight: FontWeight.w300, color: AppColors.whiteColor),
          viewLessText: 'أقل',
          viewMoreText: "المزيد",
          linkStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          supportedTypes: [
            EmailParser(onTap: (email) => log('${email.value} clicked')),
            PhoneParser(onTap: (phone) => log('click phone ${phone.value}')),
            MentionParser(onTap: (mention) => log('${mention.value} clicked')),
            BoldParser(),
            HashTagParser(
              onTap: (hash) {
                final _validHashtag = hash.value?.split('#').last;
                if (hashtag == null) {
                  context.push("${Routes.hashtagsPage}/$_validHashtag");
                  return;
                }
                if (hashtag == _validHashtag) {
                  return;
                }
                context.push("${Routes.hashtagsPage}/$hashtag");
              },
            ),
            SlashEntityParser(
              onTap: (matched) {
                final parts = matched.value?.split(":");
                final type = parts?[0];
                final id = parts?[1];
                final title = parts?.sublist(2).join(":"); // Handles ':' in title

                switch (type) {
                  case 'comic':
                    log('Open Comic (ID: $id) → $title');
                    // Navigator.pushNamed(context, '/comic/$id');
                    break;
                  case 'char':
                    log('Open Character (ID: $id) → $title');
                    break;
                  case 'novel':
                    log('Open Novel (ID: $id) → $title');
                    break;
                }
              },
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
