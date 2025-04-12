import 'package:atlas_app/imports.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart' show MultiImageProvider;

class ThirdImageViewer extends StatelessWidget {
  const ThirdImageViewer({super.key, required this.images});
  final List<ImageProvider> images;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final imageWidth = size.width;
    final firstProvider = images[0] as CachedNetworkAvifImageProvider;
    final secondProvider = images[1] as CachedNetworkAvifImageProvider;
    final thirdProvider = images[2] as CachedNetworkAvifImageProvider;

    // Calculate if there are more images beyond the first three
    final remainingCount = images.length - 3;

    return InkWell(
      onTap: () {
        MultiImageProvider multiImageProvider = MultiImageProvider(images, initialIndex: 0);
        showImageViewerPager(
          context,
          multiImageProvider,
          useSafeArea: true,
          backgroundColor: Colors.black.withValues(alpha: .85),
        );
      },
      child: Row(
        children: [
          // Left side - First image
          Expanded(
            flex: 1,
            child: CachedNetworkAvifImage(
              firstProvider.url,
              height: size.width / 2,
              cacheHeight: (imageWidth / 1.5).toInt(),
              cacheWidth: (imageWidth / 2).toInt(),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 4),
          // Right side - Second and third images stacked
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Second image
                Stack(
                  children: [
                    CachedNetworkAvifImage(
                      secondProvider.url,
                      height: imageWidth / 3,
                      width: imageWidth / 2,
                      cacheHeight: (imageWidth / 3).toInt(),
                      cacheWidth: (imageWidth / 2).toInt(),
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Third image with remaining count overlay if needed
                Stack(
                  children: [
                    CachedNetworkAvifImage(
                      thirdProvider.url,
                      height: imageWidth / 3 - 4,
                      width: imageWidth / 2,
                      cacheHeight: (imageWidth / 3).toInt(),
                      cacheWidth: (imageWidth / 2).toInt(),
                      fit: BoxFit.cover,
                    ),
                    if (remainingCount > 0)
                      Container(
                        height: imageWidth / 3 - 4,
                        width: imageWidth / 2,
                        color: Colors.black.withValues(alpha: .6),
                        alignment: Alignment.center,
                        child: Text(
                          "+$remainingCount",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
