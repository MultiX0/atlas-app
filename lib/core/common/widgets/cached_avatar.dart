import 'package:atlas_app/imports.dart';

class CachedAvatar extends StatelessWidget {
  const CachedAvatar({super.key, required this.avatar, this.raduis = 23});

  final String avatar;
  final double raduis;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: raduis,
      backgroundColor: AppColors.blackColor,
      child: CachedNetworkImage(
        imageUrl: avatar,
        memCacheWidth: 100,
        memCacheHeight: 100,
        maxHeightDiskCache: 100,
        maxWidthDiskCache: 100,
        imageBuilder:
            (context, image) => CircleAvatar(
              backgroundImage: image,
              radius: raduis,
              backgroundColor: AppColors.blackColor,
            ),
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
