import 'dart:ui';

import 'package:atlas_app/features/characters/models/character_preview_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class PostMentionEmbedWidget extends ConsumerWidget {
  const PostMentionEmbedWidget({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    List<dynamic> mixedList = [
      ...post.charactersMentioned,
      ...post.manhwaMentioned,
      ...post.novelsMentioned,
    ];

    return RepaintBoundary(
      child: FlutterCarousel.builder(
        key: ValueKey(post.postId),
        itemCount: mixedList.length,
        itemBuilder: (context, i, pi) {
          final item = mixedList[i];
          return AspectRatio(
            key: ValueKey(item.id),
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      memCacheHeight: (size.width * 0.225).toInt(),
                      memCacheWidth: size.width.toInt(),
                      fit: BoxFit.cover,
                      imageUrl:
                          item is CharacterPreviewModel
                              ? item.poster
                              : item.banner.toString().isEmpty
                              ? item.poster
                              : item.banner,
                    ),
                  ),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: const SizedBox(),
                    ),
                  ),
                  Positioned.fill(
                    child: Material(color: AppColors.scaffoldBackground.withValues(alpha: .8)),
                  ),
                  Padding(
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
                                style: const TextStyle(fontFamily: accentFont, fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.description.toString().isEmpty
                                    ? "حاليا لايوجد أي وصف لهذا العنصر, سيتم اضافة الوصف في أقرب فترة ممكنة, نشكركم على صبركم"
                                    : item.description,
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
                          child: CachedNetworkImage(imageUrl: item.poster, fit: BoxFit.cover),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        options: FlutterCarouselOptions(
          aspectRatio: 16 / 9,
          enlargeFactor: 1,
          viewportFraction: 1,
          disableCenter: true,
          slideIndicator: SequentialFillIndicator(),
        ),
      ),
    );
  }
}
