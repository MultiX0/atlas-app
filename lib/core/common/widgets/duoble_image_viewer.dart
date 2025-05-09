import 'package:atlas_app/imports.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart' show MultiImageProvider;

class DoubleImageViewer extends StatelessWidget {
  const DoubleImageViewer({super.key, required this.images});
  final List<ImageProvider> images;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final firstProvider = images[0] as CachedNetworkImageProvider;
    final secondProvider = images[1] as CachedNetworkImageProvider;

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
          Expanded(
            child: CachedNetworkImage(
              imageUrl: firstProvider.url,
              height: size.width / 2,
              maxWidthDiskCache: (size.width / 2).toInt(),
              maxHeightDiskCache: (size.width / 2).toInt(),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: CachedNetworkImage(
              imageUrl: secondProvider.url,
              height: size.width / 2,
              maxHeightDiskCache: (size.width / 2).toInt(),
              maxWidthDiskCache: (size.width / 2).toInt(),
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
