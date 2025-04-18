import 'dart:ui';

import 'package:atlas_app/features/characters/models/character_preview_model.dart';
import 'package:atlas_app/imports.dart';

class PostMentionEmbedWidget extends ConsumerWidget {
  const PostMentionEmbedWidget({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final List<dynamic> mixedList = [
      ...post.charactersMentioned,
      ...post.manhwaMentioned,
      ...post.novelsMentioned,
    ];

    return RepaintBoundary(
      child: SizedBox(
        height: 200,
        child: CarouselView.weighted(
          key: ValueKey(post.postId),
          scrollDirection: Axis.horizontal,
          flexWeights: const [1],
          shrinkExtent: size.width * .75,
          consumeMaxWeight: true,
          enableSplash: true,
          itemSnapping: true,
          backgroundColor: AppColors.scaffoldBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: AppColors.mutedSilver.withValues(alpha: .2)),
          ),
          children:
              mixedList.map((item) {
                return _MentionItemWidget(item: item);
              }).toList(),
        ),
      ),
    );
  }
}

class _MentionItemWidget extends StatelessWidget {
  const _MentionItemWidget({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item is CharacterPreviewModel ? item.name : item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: accentFont,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.description?.isNotEmpty == true
                            ? item.description
                            : "حاليا لايوجد أي وصف لهذا العنصر, سيتم اضافة الوصف في أقرب فترة ممكنة, نشكركم على صبركم",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: arabicPrimaryFont,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: item.poster,
                    fit: BoxFit.cover,
                    memCacheHeight: 140,
                    memCacheWidth: 100,
                    placeholder: (_, __) => const SizedBox.shrink(),
                    errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
