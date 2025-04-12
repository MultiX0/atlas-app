import 'package:atlas_app/core/common/utils/foreground_color.dart';
import 'package:atlas_app/core/common/utils/see_more_text.dart';
import 'package:atlas_app/features/comics/models/comic_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:url_launcher/url_launcher.dart';

class ManhwaDataBody extends ConsumerStatefulWidget {
  const ManhwaDataBody({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ManhwaDataBodyState();
}

class _ManhwaDataBodyState extends ConsumerState<ManhwaDataBody> {
  @override
  Widget build(BuildContext context) {
    final comic = ref.watch(selectedComicProvider)!;
    final seeMoreTextColor =
        comic.color == null ? AppColors.primary.withValues(alpha: .7) : HexColor(comic.color!);
    return RepaintBoundary(
      child: CustomScrollView(
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                buildCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildStatisticsColumn(title: "منشور", value: comic.posts_count.toString()),
                      buildStatisticsColumn(title: "مشاهدة", value: comic.views.toString()),
                      buildStatisticsColumn(
                        title: "المفضلة",
                        value: comic.favorite_count.toString(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                buildCard(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LanguageText(
                        accent: true,
                        "ملخص",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: arabicAccentFont,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SeeMoreWidget(
                        textDirection: TextDirection.rtl,

                        comic.ar_synopsis.trim().isEmpty
                            ? "لايوجد ملخص لهذا العمل, نحن نعمل على اضافته حاليا"
                            : comic.ar_synopsis.trim(),
                        textStyle: const TextStyle(
                          color: AppColors.mutedSilver,
                          fontFamily: arabicPrimaryFont,
                          fontSize: 14,
                        ),

                        seeMoreStyle: TextStyle(
                          color: seeMoreTextColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: accentFont,
                        ),
                        seeLessStyle: TextStyle(
                          color: seeMoreTextColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: accentFont,
                        ),

                        seeMoreText: "  عرض المزيد",
                        seeLessText: "  عرض أقل",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                buildGenres(comic),

                if (comic.externalLinks != null && comic.externalLinks!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  buildCard(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LanguageText(
                          accent: true,

                          "روابط خارجية وروابط العرض",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: arabicAccentFont,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ...comic.externalLinks!.asMap().entries.map((e) {
                          final linksColor =
                              comic.color != null ? HexColor(comic.color!) : AppColors.primary;
                          final link = e.value;
                          final i = e.key + 1;
                          return GestureDetector(
                            onTap: () => _launchUrl(link.url),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                "$i - ${link.site}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  fontFamily: enPrimaryFont,
                                  color: linksColor,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Container buildGenres(ComicModel comic) {
    final color = comic.color != null ? HexColor(comic.color!) : AppColors.blackColor;
    final textColor = getFontColorForBackground(color);

    return buildCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LanguageText(
            'التصنيفات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: arabicAccentFont,
            ),
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 10,
              runSpacing: 5,
              children:
                  comic.genres.map((genres) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        textAlign: TextAlign.end,
                        textDirection: TextDirection.rtl,
                        genres.ar_name,
                        style: TextStyle(
                          fontFamily: arabicPrimaryFont,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    await launchUrl(Uri.parse(url));
  }

  Container buildCard({
    double raduis = Spacing.normalRaduis + 5,
    required EdgeInsets padding,
    required Widget child,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.primaryAccent,
        borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
      ),
      child: child,
    );
  }

  Column buildStatisticsColumn({required String title, required String value}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.mutedSilver, fontFamily: arabicAccentFont),
        ),
        const SizedBox(height: 15),
        Text(
          value,
          style: TextStyle(
            fontFamily: arabicAccentFont,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
          ),
        ),
      ],
    );
  }
}
