import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/features/library/providers/my_favorite_state.dart';
import 'package:atlas_app/features/library/widgets/work_poster.dart';
import 'package:atlas_app/imports.dart';

class UserFavoritePage extends ConsumerStatefulWidget {
  const UserFavoritePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyWorkState();
}

class _MyWorkState extends ConsumerState<UserFavoritePage> {
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
          final me = ref.read(userState.select((state) => state.user!));
          ref.read(userFavoriteState(me.userId).notifier).fetchData();
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
      final me = ref.read(userState.select((state) => state.user!));
      ref.read(userFavoriteState(me.userId).notifier).fetchData();
      setState(() {
        fetched = true;
      });
    });
  }

  void refresh() async {
    await Future.delayed(const Duration(milliseconds: 400), () {
      final me = ref.read(userState.select((state) => state.user!));
      ref.read(userFavoriteState(me.userId).notifier).fetchData(refresh: true);
    });
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, _) {
          final me = ref.read(userState.select((state) => state.user!));

          final works = ref.watch(userFavoriteState(me.userId).select((state) => state.works));
          final isLoading = ref.watch(
            userFavoriteState(me.userId).select((state) => state.isLoading),
          );
          final loadingMore = ref.watch(
            userFavoriteState(me.userId).select((state) => state.loadingMore),
          );

          if (isLoading) {
            return const Loader();
          }

          return AppRefresh(
            onRefresh: () async => refresh(),
            child: Align(
              child: GridView.builder(
                shrinkWrap: works.isEmpty,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                controller: _scrollController,
                itemCount: works.isEmpty ? 1 : works.length + (loadingMore ? 1 : 0),
                padding: const EdgeInsets.fromLTRB(13, 15, 13, 15),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: works.isEmpty ? 1 : 3,
                  childAspectRatio: 1 / 1.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, i) {
                  if (works.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/no_data_cry_.gif', height: 130),
                          const SizedBox(height: 15),
                          const Text(
                            "لايوجد شيء في المفضلة",
                            style: TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  }
                  if (loadingMore && i == works.length) {
                    return const Center(child: Loader());
                  }
                  final work = works[i];
                  return WorkPoster(work: work);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
