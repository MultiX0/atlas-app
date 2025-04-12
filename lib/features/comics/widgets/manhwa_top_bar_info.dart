import 'package:atlas_app/imports.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ManhwaTopBarInfo extends ConsumerWidget {
  const ManhwaTopBarInfo({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comic = ref.watch(selectedComicProvider)!;
    if (comic.englishTitle.length > 40) {
      return const SizedBox(height: 50);
    }

    return Visibility(
      maintainInteractivity: false,
      maintainState: true,
      maintainSize: true,
      maintainAnimation: true,
      visible: visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 600),
        child: Container(
          color: AppColors.scaffoldBackground,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (comic.englishTitle.length < 20) ...[
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: CachedNetworkImageProvider(comic.image),
                    ),
                    const SizedBox(width: 15),
                  ],
                  Text(
                    comic.englishTitle,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
