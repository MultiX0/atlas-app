import 'package:atlas_app/imports.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SliverAppBar(
      expandedHeight: size.width * .85,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Material(
          color: AppColors.scaffoldBackground,
          child: Column(children: [buildTopHeaderShimmer(size), buildBottomHeaderShimmer()]),
        ),
      ),
      pinned: false,
      floating: true,
      snap: false,
    );
  }

  Widget buildBottomHeaderShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full name placeholder
          ShimmerPlaceholder(width: 150, height: 18, borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 8),
          // Username placeholder
          ShimmerPlaceholder(width: 100, height: 13, borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 15),
          // Bio placeholder
          ShimmerPlaceholder(
            width: double.infinity,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 20),
          // Stats container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.blackColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  buildCountShimmer(title: "متابعين"),
                  buildVerticalDivider(),
                  buildCountShimmer(title: "يتابع"),
                  buildVerticalDivider(),
                  buildCountShimmer(title: "منشور"),
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
      child: VerticalDivider(color: AppColors.mutedSilver.withValues(alpha: .15)),
    );
  }

  Widget buildTopHeaderShimmer(Size size) {
    return SizedBox(
      height: size.width * 0.45,
      child: Stack(
        children: [
          // Banner placeholder
          Opacity(
            opacity: .75,
            child: ShimmerPlaceholder(
              width: double.infinity,
              height: size.width * 0.30,
              borderRadius: BorderRadius.zero,
            ),
          ),
          // Avatar placeholder
          Positioned(
            bottom: 15,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.scaffoldBackground, width: 4),
              ),
              child: ShimmerPlaceholder(
                width: 80,
                height: 80,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          // Action buttons placeholder
          Positioned(
            bottom: 5,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ShimmerPlaceholder(width: 40, height: 30, borderRadius: BorderRadius.circular(8)),
                const SizedBox(width: 8),
                ShimmerPlaceholder(width: 30, height: 30, borderRadius: BorderRadius.circular(8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded buildCountShimmer({required String title}) => Expanded(
    child: Column(
      children: [
        ShimmerPlaceholder(width: 40, height: 16, borderRadius: BorderRadius.circular(4)),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontFamily: arabicAccentFont,
            color: AppColors.mutedSilver.withValues(alpha: .95),
          ),
        ),
      ],
    ),
  );
}

// Generic shimmer placeholder widget
class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.mutedSilver.withValues(alpha: .2),
        borderRadius: borderRadius,
      ),
      child: FancyShimmerImage(
        imageUrl: '', // Empty URL to trigger shimmer effect
        shimmerBaseColor: AppColors.mutedSilver.withValues(alpha: .3),
        shimmerHighlightColor: AppColors.mutedSilver.withValues(alpha: .5),
        boxFit: BoxFit.cover,
        errorWidget: Container(color: AppColors.mutedSilver.withValues(alpha: .2)),
      ),
    );
  }
}
