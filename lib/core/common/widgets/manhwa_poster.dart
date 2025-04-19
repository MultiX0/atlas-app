import 'package:atlas_app/imports.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

class ManhwaPoster extends StatelessWidget {
  const ManhwaPoster({
    super.key,
    required this.onTap,
    required this.image,
    this.fancyImage = true,
    required this.text,
    this.type,
  });

  final Function() onTap;
  final String image;
  final String text;
  final bool fancyImage;
  final String? type;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child:
          type != null
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 180, child: buildStack()),
                  const SizedBox(height: 10),
                  Text("النوع: $type", style: const TextStyle(fontFamily: arabicAccentFont)),
                ],
              )
              : buildStack(),
    );
  }

  Stack buildStack() {
    return Stack(
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
    );
  }
}
