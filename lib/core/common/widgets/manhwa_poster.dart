import 'package:atlas_app/imports.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

class ManhwaPoster extends StatelessWidget {
  const ManhwaPoster({
    super.key,
    required this.onTap,
    required this.image,
    this.fancyImage = true,
    required this.text,
  });

  final Function() onTap;
  final String image;
  final String text;
  final bool fancyImage;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child:
                fancyImage
                    ? FancyShimmerImage(
                      imageUrl: image,
                      shimmerBaseColor: AppColors.primaryAccent,
                      shimmerHighlightColor: AppColors.mutedSilver.withValues(alpha: .05),
                    )
                    : CachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.primaryAccent.withValues(alpha: .9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.1, 0.9],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: accentFont, fontSize: 13, color: AppColors.whiteColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
