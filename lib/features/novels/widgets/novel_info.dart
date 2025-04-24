import 'package:atlas_app/features/comics/widgets/genres_card.dart';
import 'package:atlas_app/features/comics/widgets/statisitcs_card.dart';
import 'package:atlas_app/features/comics/widgets/synposis_card.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/imports.dart';

class NovelInfo extends ConsumerStatefulWidget {
  const NovelInfo({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NovelInfoState();
}

class _NovelInfoState extends ConsumerState<NovelInfo> {
  @override
  Widget build(BuildContext context) {
    final novel = ref.watch(selectedNovelProvider)!;
    final me = ref.watch(userState.select((s) => s.user!));
    bool isMeCreator = novel.userId == me.userId;

    return RepaintBoundary(
      child: Scaffold(
        floatingActionButton:
            !isMeCreator
                ? null
                : FloatingActionButton(
                  backgroundColor: AppColors.primary.withValues(alpha: .6),
                  onPressed: () {
                    if (isMeCreator) {
                      context.push("${Routes.addNovelPage}/t");
                    }
                  },
                  child: const Icon(TablerIcons.edit),
                ),
        body: CustomScrollView(
          cacheExtent: 100,
          slivers: [
            SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  StatisticsCard(
                    favoriteCount: novel.favoriteCount,
                    postsCount: novel.postsCount,
                    views: novel.viewsCount,
                  ),
                  const SizedBox(height: 10),
                  SynopsisCard(color: novel.color, synopsis: novel.synopsis),
                  const SizedBox(height: 10),
                  GenresCard(color: novel.color, genres: novel.genrese.map((g) => g.name).toList()),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
