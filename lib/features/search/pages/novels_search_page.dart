import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/manhwa_poster.dart';
import 'package:atlas_app/features/search/providers/novel_search_state.dart';
import 'package:atlas_app/imports.dart';

class NovelsSearchPage extends ConsumerStatefulWidget {
  const NovelsSearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NovelsSearchPageState();
}

class _NovelsSearchPageState extends ConsumerState<NovelsSearchPage> {
  final ScrollController _scrollController = ScrollController();

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
          ref.read(novelSearchStateProvider.notifier).search();
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
    await Future.microtask(() {
      ref.read(novelSearchStateProvider.notifier).search();

      setState(() {
        fetched = true;
      });
    });
  }

  void refresh() async {
    await Future.delayed(const Duration(milliseconds: 400), () {
      ref.read(novelSearchStateProvider.notifier).search(refresh: true);
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
    final state = ref.watch(novelSearchStateProvider);

    final novels = state.novels;
    if (state.isLoading) {
      return const Loader();
    }

    if (state.error != null) {
      return Center(child: ErrorWidget(Exception(state.error)));
    }

    if (novels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/no_data_cry_.gif', height: 130),
            const SizedBox(height: 15),
            const Text(
              "سجل البحث فارغ",
              style: TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(13, 0, 13, 15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 1 / 1.5,
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: novels.length,
      itemBuilder: (context, i) {
        final novel = novels[i];
        return ManhwaPoster(
          key: ValueKey(novel.id),
          text: novel.title,
          onTap: () => context.push("${Routes.novelPage}/${novel.id}"),
          image: novel.poster,
        );
      },
    );
  }
}
