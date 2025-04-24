import 'package:atlas_app/features/comics/widgets/external_links_card.dart';
import 'package:atlas_app/features/comics/widgets/genres_card.dart';
import 'package:atlas_app/features/comics/widgets/statisitcs_card.dart';
import 'package:atlas_app/features/comics/widgets/synposis_card.dart';
import 'package:atlas_app/imports.dart';

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
        cacheExtent: 100,
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                StatisticsCard(
                  favoriteCount: comic.favorite_count,
                  postsCount: comic.posts_count,
                  views: comic.views,
                ),
                const SizedBox(height: 10),
                SynopsisCard(color: seeMoreTextColor, synopsis: comic.ar_synopsis),
                const SizedBox(height: 10),
                GenresCard(
                  color: seeMoreTextColor,
                  genres: comic.genres.map((g) => g.ar_name).toList(),
                ),
                if (comic.externalLinks != null && comic.externalLinks!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ExternalLinksCard(comic: comic),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
