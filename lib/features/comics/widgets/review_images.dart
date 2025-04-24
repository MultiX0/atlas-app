import 'package:atlas_app/imports.dart';
import 'package:atlas_app/core/common/widgets/image_view_controller.dart';

class ReviewImages extends StatelessWidget {
  const ReviewImages({super.key, required this.imageUrls, this.imageProviders});

  final List<String> imageUrls;
  final List<ImageProvider>? imageProviders;

  @override
  Widget build(BuildContext context) {
    final providers =
        imageProviders ?? imageUrls.map((url) => CachedNetworkAvifImageProvider(url)).toList();
    return ViewImagesController(images: providers);
  }
}
