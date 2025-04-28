import 'package:atlas_app/core/common/enum/post_like_enum.dart';
import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/features/novels/widgets/empty_chapters.dart';
import 'package:atlas_app/features/posts/providers/main_feed_state.dart';
import 'package:atlas_app/features/posts/widgets/main_feed_appbar.dart';
import 'package:atlas_app/features/profile/widgets/post_widget.dart';
import 'package:atlas_app/imports.dart';

class MainFeedPage extends ConsumerStatefulWidget {
  const MainFeedPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainFeedPageState();
}

class _MainFeedPageState extends ConsumerState<MainFeedPage> {
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
          ref.read(mainFeedStateProvider(userId).notifier).fetchData();
        },
      );
    }
    _previousScroll = currentScroll;
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    const delta = 300.0;
    return currentScroll > _previousScroll + 10 && maxScroll - currentScroll <= delta;
  }

  void fetchData() async {
    final me = ref.read(userState.select((s) => s.user!));
    setState(() {
      userId = me.userId;
    });
    await Future.microtask(() {
      ref.read(mainFeedStateProvider(me.userId).notifier).fetchData();

      setState(() {
        fetched = true;
      });
    });
  }

  void refresh() async {
    await Future.delayed(const Duration(milliseconds: 400), () {
      ref.read(mainFeedStateProvider(userId).notifier).fetchData(refresh: true);
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
    final state = ref.watch(mainFeedStateProvider(userId));

    final posts = state.posts;

    if (state.error != null) {
      return Center(child: ErrorWidget(Exception(state.error)));
    }

    return SafeArea(
      child: AppRefresh(
        onRefresh: () async => refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          cacheExtent: MediaQuery.sizeOf(context).height * 1.5,
          slivers: [
            const MainFeedAppbar(),
            if (state.isLoading)
              const SliverFillRemaining(child: Loader())
            else
              SliverList.builder(
                addRepaintBoundaries: true,
                addSemanticIndexes: true,
                itemCount: posts.isEmpty ? 1 : posts.length + (state.loadingMore ? 1 : 0),
                itemBuilder: (context, i) {
                  if (posts.isEmpty && i == 0) {
                    return const EmptyChapters(text: "لايوجد هنالك محتوى");
                  }

                  if (i == posts.length && state.loadingMore) {
                    return const Loader();
                  }

                  final post = posts[i];
                  return PostWidget(
                    key: ValueKey(post.postId),
                    post: post,
                    onComment: () => CustomToast.soon(),
                    onShare: () => CustomToast.soon(),
                    postLikeType: PostLikeEnum.GENERAL,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
