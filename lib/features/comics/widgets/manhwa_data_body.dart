import 'package:atlas_app/core/common/utils/see_more_text.dart';
import 'package:atlas_app/features/auth/providers/user_state.dart';
import 'package:atlas_app/features/comics/models/comic_model.dart';
import 'package:atlas_app/features/comics/providers/providers.dart';
import 'package:atlas_app/features/navs/navs.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
    final me = ref.watch(userState)!;
    final seeMoreTextColor =
        comic.color == null ? AppColors.primary.withValues(alpha: .7) : HexColor(comic.color!);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      children: [
        buildCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildStatisticsColumn(title: "Posts", value: "21.7K"),
              buildStatisticsColumn(title: "Views", value: "16.5K"),
              buildStatisticsColumn(title: "Reviews", value: "1.2K"),
            ],
          ),
        ),
        const SizedBox(height: 10),
        buildCard(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Synopsis",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: accentFont),
              ),
              const SizedBox(height: 5),
              SeeMoreWidget(
                comic.synopsis.trim().isEmpty
                    ? "There is not synopsis for this work"
                    : comic.synopsis.trim(),
                textStyle: const TextStyle(color: AppColors.mutedSilver, fontFamily: primaryFont),
                seeMoreStyle: TextStyle(color: seeMoreTextColor, fontWeight: FontWeight.bold),
                seeLessStyle: TextStyle(color: seeMoreTextColor, fontWeight: FontWeight.bold),
                seeMoreText: "  See More",
                seeLessText: "  See Less",
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        buildCard(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    const Text(
                      "Reviews",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: accentFont,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      child: const Row(
                        children: [
                          Text("See all"),
                          SizedBox(width: 5),
                          Icon(LucideIcons.chevron_right),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.scaffoldBackground,
                  border: Border.all(color: AppColors.blackColor, width: 3),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: CachedNetworkAvifImageProvider(me.user!.avatar),
                        ),
                        const SizedBox(width: 15),
                        Text("@${me.user!.username}"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "In the beginning, I didn’t have very high expectations for any manga (much less think I would write a review for it, but look at me now lol). It never gave me the hype that anime did, especially in the case of fight scenes. In my eyes, manga was always inferior to anime, that is, until I read this…..",
                      style: TextStyle(color: AppColors.mutedSilver),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              buildRatingBar(comic),
            ],
          ),
        ),
        if (comic.externalLinks != null && comic.externalLinks!.isNotEmpty) ...[
          const SizedBox(height: 10),
          buildCard(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "External & Streaming links",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: accentFont,
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
      ],
    );
  }

  Widget buildRatingBar(ComicModel comic) {
    final starColor = comic.color != null ? HexColor(comic.color!) : AppColors.primary;

    return Center(
      child: GestureDetector(
        onTap: () => ref.read(navsProvider).goToAddComicReviewPage(),
        child: RatingBarIndicator(
          itemPadding: const EdgeInsets.symmetric(horizontal: 5),
          rating: 3,
          itemBuilder: (context, index) => Icon(Icons.star, color: starColor),
          itemCount: 6,
          itemSize: 40.0,
          direction: Axis.horizontal,
        ),
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
        Text(title, style: const TextStyle(color: AppColors.mutedSilver)),
        const SizedBox(height: 15),
        Text(
          value,
          style: TextStyle(
            fontFamily: accentFont,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
          ),
        ),
      ],
    );
  }
}
