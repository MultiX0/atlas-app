import 'dart:developer';

import 'package:atlas_app/features/posts/models/post_model.dart';
import 'package:atlas_app/features/profile/widgets/interactions_bar.dart';
import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';
import 'package:rich_text_view/rich_text_view.dart';
import 'dart:ui' as ui;
import 'package:timeago/timeago.dart' as timeago;

class PostWidget extends ConsumerWidget {
  const PostWidget({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = post.user;
    final hasArabic = Bidi.hasAnyRtl("Who else thinks it's thinks");
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Column(
        crossAxisAlignment: hasArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,

        children: [
          buildPostHeader(user),
          const SizedBox(height: 10),
          buildContentText(hasArabic),
          const SizedBox(height: 12),
          InteractionBar(
            likes: 120,
            comments: 45,
            reposts: 12,
            isLiked: post.userLiked,
            onLike: (_) async => true,
            onComment: () => log("Comment tapped"),
            onRepost: () => log("Reposted!"),
            onShare: () => log("Share tapped"),
          ),

          const SizedBox(height: 15),
          Divider(height: 0.25, color: AppColors.mutedSilver.withValues(alpha: .15)),
        ],
      ),
    );
  }

  Widget buildPostHeader(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: AppColors.primaryAccent,
            backgroundImage: CachedNetworkAvifImageProvider(post.user.avatar),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text("·"),
                    const SizedBox(width: 5),
                    Text(
                      timeago.format(post.createdAt, locale: "ar"),
                      style: const TextStyle(color: AppColors.mutedSilver, fontSize: 12),
                    ),
                  ],
                ),

                Text(
                  "@${user.username}",
                  style: const TextStyle(fontSize: 13, color: AppColors.mutedSilver),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(TablerIcons.dots, color: AppColors.mutedSilver),
            iconSize: 18,
          ),
        ],
      ),
    );
  }

  Widget buildContentText(bool hasArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: RichTextView(
        textDirection: hasArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        text:
            'Just had an amazing brainstorming session with @alex_dev and @uiqueen! 🚀 Excited to start working on the next phase of our #AI project. Big things coming soon! 🔥 Check it out here: https://example.com/project-update #TechLife #StartupJourney #Innovation 💡',
        maxLines: 5,
        truncate: true,
        viewLessText: 'أقل',
        viewMoreText: "المزيد",
        linkStyle: const TextStyle(color: Colors.blue),
        supportedTypes: [
          EmailParser(onTap: (email) => print('${email.value} clicked')),
          PhoneParser(onTap: (phone) => print('click phone ${phone.value}')),
          MentionParser(onTap: (mention) => print('${mention.value} clicked')),
          UrlParser(onTap: (url) => print('visting ${url.value}?')),
          BoldParser(),
          HashTagParser(onTap: (hashtag) => print('is ${hashtag.value} trending?')),
        ],
      ),
    );
  }
}
