import 'package:atlas_app/imports.dart';
import 'package:shimmer/shimmer.dart';

class NovelDetailShimmer extends StatelessWidget {
  const NovelDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return CustomScrollView(
      cacheExtent: 100,
      slivers: [
        // Header Section (Mimicking NovelHeader)
        SliverToBoxAdapter(
          child: RepaintBoundary(
            child: SizedBox(
              height: size.width * 0.65,
              child: Stack(
                children: [
                  // Banner Placeholder
                  Shimmer.fromColors(
                    baseColor: AppColors.mutedSilver.withValues(alpha: .3),
                    highlightColor: AppColors.whiteColor.withValues(alpha: .1),
                    child: Container(
                      width: double.infinity,
                      height: size.width * 0.55,
                      color: AppColors.mutedSilver,
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    height: size.width * 0.6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, AppColors.scaffoldBackground],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.1, 0.8],
                      ),
                    ),
                  ),
                  // Poster and Text Placeholders
                  Positioned(
                    bottom: 0,
                    left: 15,
                    right: 15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Poster Placeholder
                            Shimmer.fromColors(
                              baseColor: AppColors.mutedSilver.withValues(alpha: .3),
                              highlightColor: AppColors.whiteColor.withValues(alpha: .1),
                              child: Container(
                                width: 120,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: AppColors.mutedSilver,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            const SizedBox(width: 25),
                            // Title and Info Placeholders
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Title Placeholder
                                  Shimmer.fromColors(
                                    baseColor: AppColors.mutedSilver.withValues(alpha: .3),
                                    highlightColor: AppColors.whiteColor.withValues(alpha: .1),
                                    child: Container(
                                      width: size.width * 0.5,
                                      height: 20,
                                      color: AppColors.mutedSilver,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Publication Date Placeholder
                                  Shimmer.fromColors(
                                    baseColor: AppColors.mutedSilver.withValues(alpha: .3),
                                    highlightColor: AppColors.whiteColor.withValues(alpha: .1),
                                    child: Container(
                                      width: size.width * 0.4,
                                      height: 16,
                                      color: AppColors.mutedSilver,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Author Placeholder
                                  Shimmer.fromColors(
                                    baseColor: AppColors.mutedSilver.withValues(alpha: .3),
                                    highlightColor: AppColors.whiteColor.withValues(alpha: .1),
                                    child: Container(
                                      width: size.width * 0.3,
                                      height: 16,
                                      color: AppColors.mutedSilver,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  // Action Buttons Placeholder
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Shimmer.fromColors(
                          baseColor: AppColors.mutedSilver.withValues(alpha: .3),
                          highlightColor: AppColors.whiteColor.withValues(alpha: .1),
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.mutedSilver,
                          ),
                        ),
                        const Spacer(),
                        Shimmer.fromColors(
                          baseColor: AppColors.mutedSilver.withValues(alpha: .3),
                          highlightColor: AppColors.whiteColor.withValues(alpha: .1),
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.mutedSilver,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Shimmer.fromColors(
                          baseColor: AppColors.mutedSilver.withValues(alpha: .3),
                          highlightColor: AppColors.whiteColor.withValues(alpha: .1),
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.mutedSilver,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Info Section (Mimicking NovelInfo)
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Statistics Card Placeholder
              Shimmer.fromColors(
                baseColor: AppColors.mutedSilver.withValues(alpha: .3),
                highlightColor: AppColors.whiteColor.withValues(alpha: .1),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mutedSilver,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      3,
                      (_) => Column(
                        children: [
                          Container(width: 50, height: 16, color: AppColors.mutedSilver),
                          const SizedBox(height: 8),
                          Container(width: 30, height: 16, color: AppColors.mutedSilver),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Synopsis Card Placeholder
              Shimmer.fromColors(
                baseColor: AppColors.mutedSilver.withValues(alpha: .3),
                highlightColor: AppColors.whiteColor.withValues(alpha: .1),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mutedSilver,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: size.width * 0.3, height: 18, color: AppColors.mutedSilver),
                      const SizedBox(height: 15),
                      Container(width: double.infinity, height: 16, color: AppColors.mutedSilver),
                      const SizedBox(height: 8),
                      Container(width: double.infinity, height: 16, color: AppColors.mutedSilver),
                      const SizedBox(height: 8),
                      Container(width: size.width * 0.7, height: 16, color: AppColors.mutedSilver),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Genres Card Placeholder
              Shimmer.fromColors(
                baseColor: AppColors.mutedSilver.withValues(alpha: .3),
                highlightColor: AppColors.whiteColor.withValues(alpha: .1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.mutedSilver,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: size.width * 0.3, height: 18, color: AppColors.mutedSilver),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 5,
                        alignment: WrapAlignment.end,
                        children: List.generate(
                          4,
                          (_) => Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.mutedSilver,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
