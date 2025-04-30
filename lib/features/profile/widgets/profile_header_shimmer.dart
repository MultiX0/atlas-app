import 'package:atlas_app/imports.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:shimmer/shimmer.dart';

class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  final double avatarRadius = 40.0;
  final double avatarBorder = 4.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double bannerHeight = size.width * 0.30;
    final double avatarVisibleOverlap = avatarRadius + avatarBorder;
    final double topHeaderHeight = bannerHeight + avatarVisibleOverlap + 10;
    const double bottomHeaderEstimatedHeight = 180.0;
    final double totalExpandedHeight = topHeaderHeight + bottomHeaderEstimatedHeight;

    return SliverAppBar(
      expandedHeight: totalExpandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Material(
          color: AppColors.scaffoldBackground,
          child: Column(
            children: [
              buildTopHeaderShimmer(size, bannerHeight, topHeaderHeight),
              buildBottomHeaderShimmer(),
            ],
          ),
        ),
      ),
      pinned: false,
      floating: true,
      snap: false,
    );
  }

  Widget buildTopHeaderShimmer(Size size, double bannerHeight, double totalTopHeaderHeight) {
    return SizedBox(
      height: totalTopHeaderHeight,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: bannerHeight,
            child: Opacity(
              opacity: 0.75,
              child: FancyShimmerImage(
                imageUrl: '',
                boxFit: BoxFit.cover,
                shimmerBaseColor: Colors.grey[300],
                shimmerHighlightColor: Colors.grey[100],
              ),
            ),
          ),
          Positioned(
            top: bannerHeight - (avatarRadius + avatarBorder),
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.scaffoldBackground, width: avatarBorder),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: avatarRadius,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 15,
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 40,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomHeaderShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(width: 150, height: 20, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(width: 100, height: 14, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(width: double.infinity, height: 16, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.blackColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  buildCountShimmer(),
                  buildVerticalDivider(),
                  buildCountShimmer(),
                  buildVerticalDivider(),
                  buildCountShimmer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildVerticalDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: VerticalDivider(color: AppColors.mutedSilver.withAlpha(38)),
    );
  }

  Expanded buildCountShimmer() {
    return Expanded(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(width: 50, height: 16, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(width: 50, height: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
