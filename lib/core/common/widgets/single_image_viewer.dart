import 'dart:math';

import 'package:atlas_app/imports.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart' show MultiImageProvider;

class SingleImageViewer extends StatelessWidget {
  const SingleImageViewer({super.key, required this.images});
  final List<ImageProvider> images;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final provider = images.first as CachedNetworkImageProvider;
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
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: size.height * .5, minWidth: size.width),
        child: SizedBox(
          width: 500,
          height: 500,
          child: Material(
            color: AppColors.secondBlackColor,
            child: CachedNetworkImage(
              imageUrl: provider.url,
              fit: BoxFit.cover,
              maxHeightDiskCache: min(size.width.toInt(), 500), // Cap at 500px
              maxWidthDiskCache: min(size.width.toInt(), 500),
              errorWidget:
                  (context, url, error) =>
                      Container(color: Colors.grey[600], child: const Icon(Icons.broken_image)),
            ),
          ),
        ),
      ),
    );
  }
}
