import 'package:atlas_app/core/common/widgets/image_view_controller.dart';
import 'package:atlas_app/imports.dart';

class ReviewImages extends StatelessWidget {
  ReviewImages({super.key, required this.review})
    : imageProviders = review.images.map((image) => CachedNetworkAvifImageProvider(image)).toList();

  final ComicReviewModel review;
  final List<ImageProvider> imageProviders;
  @override
  Widget build(BuildContext context) {
    return ViewImagesController(images: imageProviders);
  }
}
