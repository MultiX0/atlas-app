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

    return RepaintBoundary(
      child: CustomScrollView(
        cacheExtent: 100,
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                StatisticsCard(comic: comic),
                const SizedBox(height: 10),
                SynopsisCard(comic: comic),
                const SizedBox(height: 10),
                GenresCard(comic: comic),
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
