import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/features/explore/providers/novels_explore_state.dart';
import 'package:atlas_app/features/explore/widgets/explore_card.dart';
import 'package:atlas_app/features/novels/widgets/empty_chapters.dart';
import 'package:atlas_app/imports.dart';

class ExploreNovelsPage extends ConsumerStatefulWidget {
  const ExploreNovelsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExploreNovelsPageState();
}

class _ExploreNovelsPageState extends ConsumerState<ExploreNovelsPage> {
  final ScrollController _scrollController = ScrollController();
  String userId = '';

  bool fetched = false;
  final Debouncer _debouncer = Debouncer();
  double _previousScroll = 0.0;
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

  DateTime? _lastCheck;
  void _onScroll() {
    final currentScroll = _scrollController.position.pixels;
    final now = DateTime.now();
    if (_lastCheck != null && now.difference(_lastCheck!).inMilliseconds < 500) return;
    _lastCheck = now;
    if (_isBottom) {
      const duration = Duration(milliseconds: 500);
      _debouncer.debounce(
        duration: duration,
        onDebounce: () {
          ref.read(novelExploreProvider(userId).notifier).fetchData();
        },
      );
    }
    _previousScroll = currentScroll;
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    const delta = 200.0;
    return currentScroll > _previousScroll + 10 && maxScroll - currentScroll <= delta;
  }

  void fetchData() async {
    final me = ref.read(userState.select((s) => s.user!));
    setState(() {
      userId = me.userId;
    });
    await Future.microtask(() {
      ref.read(novelExploreProvider(me.userId).notifier).fetchData();

      setState(() {
        fetched = true;
      });
    });
  }

  void refresh() async {
    await Future.delayed(const Duration(milliseconds: 400), () {
      ref.read(novelExploreProvider(userId).notifier).fetchData(refresh: true);
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
    final state = ref.watch(novelExploreProvider(userId));

    final novels = state.novels;
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
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
        cacheExtent: MediaQuery.sizeOf(context).height * 1.5,
        addRepaintBoundaries: true,
        addSemanticIndexes: true,
        itemCount: novels.isEmpty ? 1 : novels.length + (state.loadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (novels.isEmpty && i == 0) {
            return const EmptyChapters(text: "لايوجد هنالك محتوى");
          }

          if (i == novels.length && state.loadingMore) {
            return const Loader();
          }

          final novel = novels[i];
          return ExploreCard(
            key: ValueKey(novel.id),
            color: novel.color,
            id: novel.id,
            onTap: () => context.push("${Routes.novelPage}/${novel.id}"),
            poster: novel.poster,
            title: novel.title,
            banner: novel.banner.isEmpty ? null : novel.banner,
            description: novel.description,
          );
        },
      ),
    );
  }
}
