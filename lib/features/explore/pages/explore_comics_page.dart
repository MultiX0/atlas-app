import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/features/explore/providers/comics_explore_state.dart';
import 'package:atlas_app/features/explore/widgets/explore_card.dart';
import 'package:atlas_app/features/novels/widgets/empty_chapters.dart';
import 'package:atlas_app/imports.dart';

class ExploreComicsPage extends ConsumerStatefulWidget {
  const ExploreComicsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExploreNovelsPageState();
}

class _ExploreNovelsPageState extends ConsumerState<ExploreComicsPage> {
  final ScrollController _scrollController = ScrollController();

  bool fetched = false;
  final Debouncer _debouncer = Debouncer();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!fetched) {
        fetchData();
      }
      _scrollController.addListener(_onScroll);
    });
    super.initState();
  }

  void _onScroll() {
    if (_isBottom) {
      const duration = Duration(milliseconds: 100);
      _debouncer.debounce(
        duration: duration,
        onDebounce: () {
          ref.read(comicsExploreProvider.notifier).fetchData();
        },
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    var threshold = MediaQuery.sizeOf(context).height / 2;

    return maxScroll - currentScroll <= threshold;
  }

  void fetchData() async {
    await Future.microtask(() {
      ref.read(comicsExploreProvider.notifier).fetchData();

      setState(() {
        fetched = true;
      });
    });
  }

  void refresh() async {
    await Future.delayed(const Duration(milliseconds: 400), () {
      ref.read(comicsExploreProvider.notifier).fetchData(refresh: true);
    });
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comicsExploreProvider);

    final comics = state.comics;
    if (state.isLoading) {
      return const Loader();
    }

    if (state.error != null) {
      return Center(child: ErrorWidget(Exception(state.error)));
    }

    return AppRefresh(
      onRefresh: () async => refresh(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
        cacheExtent: MediaQuery.sizeOf(context).height * 1.5,
        addRepaintBoundaries: true,
        addSemanticIndexes: true,
        itemCount: comics.isEmpty ? 1 : comics.length + (state.loadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (comics.isEmpty && i == 0) {
            return const EmptyChapters(text: "لايوجد هنالك محتوى");
          }

          if (i == comics.length && state.loadingMore) {
            return const Loader();
          }

          final comic = comics[i];
          return ExploreCard(
            key: ValueKey(comic.id),
            color: comic.color,
            id: comic.id,
            onTap: () => context.push("${Routes.comicPage}/${comic.id}"),
            poster: comic.poster,
            title: comic.title,
            banner: comic.banner.isEmpty ? null : comic.banner,
            description: comic.description,
          );
        },
      ),
    );
  }
}
