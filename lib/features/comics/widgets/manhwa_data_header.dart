import 'package:atlas_app/core/common/utils/app_date_format.dart';
import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/features/comics/providers/providers.dart';
import 'package:atlas_app/imports.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

class ManhwaDataHeader extends ConsumerStatefulWidget {
  const ManhwaDataHeader({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ManhwaDataHeaderState();
}

class _ManhwaDataHeaderState extends ConsumerState<ManhwaDataHeader> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final comic = ref.watch(selectedComicProvider)!;
    final shadowColor =
        comic.color != null
            ? HexColor(comic.color!).withValues(alpha: .25)
            : AppColors.mutedSilver.withValues(alpha: .15);

    return SliverToBoxAdapter(
      child: SizedBox(
        height: size.width * 0.65,

        child: Stack(
          children: [
            if (comic.banner != null) ...[
              FancyShimmerImage(
                imageUrl: comic.banner!,
                boxFit: BoxFit.cover,
                width: double.infinity,
                height: size.width * 0.55,
              ),
            ],
            Positioned.fill(
              child: Container(
                height: size.width * 0.6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      comic.banner != null
                          ? AppColors.scaffoldBackground.withValues(alpha: .5)
                          : AppColors.primaryAccent,
                      AppColors.scaffoldBackground,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.1, comic.banner != null ? 0.8 : 0.6],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -15,
              left: 15,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppColors.scaffoldBackground, width: 2),
                          boxShadow: [
                            BoxShadow(blurRadius: 25, spreadRadius: 0.1, color: shadowColor),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: FancyShimmerImage(imageUrl: comic.image, width: 120, height: 180),
                        ),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 15,
                                spreadRadius: 0.1,
                                color: AppColors.scaffoldBackground.withValues(alpha: .2),
                                offset: const Offset(-25, -15),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Text(
                                  comic.englishTitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: accentFont,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Text(
                                "Published: ${comic.publishedDate.from == null ? "N/A" : appDateFormat(comic.publishedDate.from!)}",
                              ),
                              Text("Status: ${comic.status.toLowerCase()}"),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                decoration: BoxDecoration(color: AppColors.primaryAccent),
                                child: Text(
                                  "Chapters: ${comic.chapters ?? "uknown"}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.scaffoldBackground,
                    child: IconButton(
                      color: AppColors.whiteColor,
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      tooltip: "Back",
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: AppColors.scaffoldBackground,
                    child: IconButton(
                      color: AppColors.whiteColor,
                      onPressed: () => CustomToast.soon(),
                      icon: const Icon(TablerIcons.heart_plus),
                      tooltip: "Back",
                    ),
                  ),
                  const SizedBox(width: 15),
                  CircleAvatar(
                    backgroundColor: AppColors.scaffoldBackground,
                    child: IconButton(
                      color: AppColors.whiteColor,
                      onPressed: () => CustomToast.soon(),
                      icon: const Icon(TablerIcons.share_2),
                      tooltip: "Back",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
