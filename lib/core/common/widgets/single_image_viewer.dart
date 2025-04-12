import 'package:atlas_app/imports.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart' show MultiImageProvider;

class SingleImageViewer extends StatelessWidget {
  const SingleImageViewer({super.key, required this.images});
  final List<ImageProvider> images;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final provider = images.first as CachedNetworkAvifImageProvider;
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
      child: CachedNetworkAvifImage(
        provider.url,
        cacheHeight: size.width.toInt(),
        cacheWidth: size.width.toInt(),
      ),
    );
  }
}
