import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/imports.dart';

class NovelChapterInteractions extends StatefulWidget {
  const NovelChapterInteractions({super.key});

  @override
  State<NovelChapterInteractions> createState() => _NovelChapterInteractionsState();
}

class _NovelChapterInteractionsState extends State<NovelChapterInteractions> {
  final Debouncer _debouncer = Debouncer();
  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle countStyle = TextStyle(fontSize: 14, color: Colors.grey.shade400);

    return Consumer(
      builder: (context, ref, _) {
        final chapter = ref.watch(selectedChapterProvider)!;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomLikeButton(
                    onTap: (a) async {
                      _debouncer.debounce(
                        duration: const Duration(milliseconds: 300),
                        onDebounce: () {
                          ref.read(novelsControllerProvider.notifier).handleChapterLike(chapter);
                        },
                      );
                      return true;
                    },
                    isLiked: chapter.isLiked,
                    counterStyle: countStyle,
                    likeCount: chapter.likeCount,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _InteractionButton(
                icon: LucideIcons.message_circle,
                count: chapter.commentsCount,
                onPressed: () => context.push(Routes.chapterCommentsPage),
                tooltip: 'التعليقات',
                countStyle: countStyle,
              ),
            ),
            Expanded(
              child: _InteractionButton(
                icon: TablerIcons.eye,
                count: chapter.views,
                onPressed: null,
                tooltip: 'المشاهدات',
                countStyle: countStyle,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onPressed;
  final String tooltip;
  final TextStyle countStyle;
  final Color iconColor;

  const _InteractionButton({
    required this.icon,
    required this.count,
    required this.onPressed,
    required this.tooltip,
    required this.countStyle,
  }) : iconColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          if (onPressed != null) {
            onPressed!();
          }
          return;
        },
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(formatNumber(count), style: countStyle),
          ],
        ),
      ),
    );
  }
}
