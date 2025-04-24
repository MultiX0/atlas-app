import 'package:atlas_app/features/characters/models/character_preview_model.dart';
import 'package:atlas_app/features/comics/models/comic_preview_model.dart';
import 'package:atlas_app/imports.dart';

import '../../novels/models/novel_preview_model.dart';

class PostMentionEmbedWidget extends ConsumerWidget {
  const PostMentionEmbedWidget({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamic firstItem =
        [...post.charactersMentioned, ...post.manhwaMentioned, ...post.novelsMentioned].first;

    return RepaintBoundary(
      child: SizedBox(
        height: 160,
        child: Material(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: () {
              // Define your onTap action here
              if (firstItem is NovelPreviewModel) {
                context.push("${Routes.novelPage}/${firstItem.id}");
              }
              if (firstItem is ComicPreviewModel) {
                context.push("${Routes.comicPage}/${firstItem.id}");
              }
            },
            splashColor: AppColors.mutedSilver.withValues(alpha: .2),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.mutedSilver.withValues(alpha: .2)),
              ),
              child: _MentionItemWidget(item: firstItem),
            ),
          ),
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
    return RepaintBoundary(
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
                    maxLines: 1,
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
                    softWrap: true,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: arabicPrimaryFont, color: Colors.white70),
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
    );
  }
}
