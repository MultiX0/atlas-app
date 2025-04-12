import 'package:atlas_app/core/common/widgets/duoble_image_viewer.dart';
import 'package:atlas_app/core/common/widgets/single_image_viewer.dart';
import 'package:atlas_app/core/common/widgets/third_image_viewer.dart';
import 'package:atlas_app/imports.dart';

class ViewImagesController extends StatelessWidget {
  const ViewImagesController({super.key, required this.images});
  final List<ImageProvider> images;

  @override
  Widget build(BuildContext context) {
    switch (images.length) {
      case 1:
        return RepaintBoundary(child: SingleImageViewer(images: images));
      case 2:
        return RepaintBoundary(child: DoubleImageViewer(images: images));
      default:
        return RepaintBoundary(child: ThirdImageViewer(images: images));
    }
  }
}
