import 'package:atlas_app/core/common/widgets/cached_avatar.dart';
import 'package:atlas_app/imports.dart';

class ExploreCard extends StatelessWidget {
  const ExploreCard({
    super.key,
    required this.id,
    required this.title,
    required this.poster,
    required this.color,
    this.description,
    this.banner,
    this.onTap,
    this.borderColor = AppColors.mutedSilver,
    this.borderWidth = 1.25,
    this.borderRadius = Spacing.normalRaduis,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.bannerHeight = 120,
    this.avatarRadius = 35,
    this.titleStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.descriptionStyle = const TextStyle(color: AppColors.mutedSilver, fontSize: 13),
    this.showDescription = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
  });

  final String id;
  final String title;
  final String poster;
  final String color;
  final String? description;
  final String? banner;
  final VoidCallback? onTap;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final double bannerHeight;
  final double avatarRadius;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final bool showDescription;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor.withValues(alpha: 0.15), width: borderWidth),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: bannerHeight,
              child: Stack(
                children: [
                  if (banner != null && banner!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderRadius),
                        topRight: Radius.circular(borderRadius),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: banner!,
                        fit: BoxFit.cover,
                        height: bannerHeight * 0.75,
                        width: double.infinity,
                      ),
                    ),
                  ] else ...[
                    Container(
                      height: bannerHeight * 0.75,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [HexColor(color), HexColor(color).withValues(alpha: .25)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(borderRadius),
                          topRight: Radius.circular(borderRadius),
                        ),
                      ),
                    ),
                  ],
                  Positioned.fill(
                    child: Material(color: AppColors.scaffoldBackground.withValues(alpha: 0.25)),
                  ),
                  Positioned(
                    left: 15,
                    bottom: 0,
                    child: CachedAvatar(avatar: poster, raduis: avatarRadius),
                  ),
                ],
              ),
            ),
            Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (showDescription && description != null) ...[
                    Text(
                      description!,
                      style: descriptionStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
