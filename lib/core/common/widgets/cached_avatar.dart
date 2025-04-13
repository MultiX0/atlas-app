import 'package:atlas_app/imports.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedAvatar extends StatelessWidget {
  const CachedAvatar({super.key, required this.avatar, this.raduis = 23});

  final String avatar;
  final double raduis;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: avatar,
      memCacheWidth: 24,
      memCacheHeight: 24,
      maxHeightDiskCache: 24,
      maxWidthDiskCache: 24,
      imageBuilder: (context, image) => CircleAvatar(backgroundImage: image, radius: raduis),
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
