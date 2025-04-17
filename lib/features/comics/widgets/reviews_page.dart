import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/imports.dart';

class ComicReviewsPage extends ConsumerStatefulWidget {
  const ComicReviewsPage({
    super.key,
    required this.comic,
    required this.tabController,
    required this.tabIndex,
  });

  final ComicModel comic;
  final TabController tabController;
  final int tabIndex;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends ConsumerState<ComicReviewsPage> {
  final ScrollController _scrollController = ScrollController();
  late final Color color;
  late final Color fontColorForBackground;
  bool fetched = false;
  int? reviewsCount;
  bool hideFloating = false;
  @override
  void initState() {
    color = widget.comic.color != null ? HexColor(widget.comic.color!) : AppColors.primary;
    fontColorForBackground = (color.computeLuminance() > 0.128) ? Colors.black : Colors.white;
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
    final now = DateTime.now();
    if (_lastCheck != null && now.difference(_lastCheck!).inMilliseconds < 500) return;
    _lastCheck = now;
    if (_isBottom) {
      ref.read(manhwaReviewsStateProvider(widget.comic.comicId).notifier).fetchReviews();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 100);
  }

  void fetchData() {
    Future.microtask(() async {
      ref.read(manhwaReviewsStateProvider(widget.comic.comicId).notifier).fetchReviews();
      final _count = await ref
          .read(reviewsControllerProvider.notifier)
          .getManhwaReviewsCount(widget.comic.comicId);
      setState(() {
        fetched = true;
        reviewsCount = _count;
      });
      final initialReviews = ref
          .read(manhwaReviewsStateProvider(widget.comic.comicId))
          .reviews
          .take(3);
      for (var review in initialReviews) {
        for (var image in review.images) {
          // ignore: use_build_context_synchronously
          precacheImage(CachedNetworkAvifImageProvider(image), context);
        }
      }
    });
  }

  void refresh() async {
    await Future.delayed(const Duration(milliseconds: 800), () async {
      ref
          .read(manhwaReviewsStateProvider(widget.comic.comicId).notifier)
          .refresh(widget.comic.comicId);
      final _count = await ref
          .read(reviewsControllerProvider.notifier)
          .getManhwaReviewsCount(widget.comic.comicId);

      setState(() {
        reviewsCount = _count;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void addReview(List<ComicReviewModel> reviews, bool iAlreadyReviewdOnce) {
    if (reviews.isEmpty || !iAlreadyReviewdOnce) {
      ref.read(navsProvider).goToAddComicReviewPage('f');
    } else {
      ref.read(navsProvider).goToMakePostPage(PostType.comic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentTab = widget.tabController.index == widget.tabIndex;

    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(
          manhwaReviewsStateProvider(widget.comic.comicId).select((state) => state.isLoading),
        );

        if (isLoading) {
          return const Loader();
        }

        return child!;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: Consumer(
          builder: (context, ref, child) {
            final userHaveReviewBefore = ref.watch(
              manhwaReviewsStateProvider(
                widget.comic.comicId,
              ).select((state) => state.user_have_review_before),
            );
            final iAlreadyReviwedOnce = userHaveReviewBefore;

            return hideFloating
                ? const SizedBox.shrink()
                : FloatingActionButton(
                  onPressed:
                      () => addReview(
                        ref.read(
                          manhwaReviewsStateProvider(
                            widget.comic.comicId,
                          ).select((state) => state.reviews),
                        ),
                        iAlreadyReviwedOnce,
                      ),
                  backgroundColor: color,
                  tooltip: "اضافة مراجعة",
                  child: Icon(TablerIcons.edit, color: fontColorForBackground),
                );
          },
        ),
        body: AppRefresh(
          onRefresh: () async => refresh(),
          child: CustomScrollView(
            cacheExtent: MediaQuery.sizeOf(context).height * 1.5,
            primary: isCurrentTab,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.normal),
            ),
            controller: isCurrentTab ? null : _scrollController,
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final reviews = ref.watch(
                    manhwaReviewsStateProvider(
                      widget.comic.comicId,
                    ).select((state) => state.reviews),
                  );

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    sliver: ReviewsWidget(
                      key: UniqueKey(),
                      iAlreadyReviewdOnce: ref.read(
                        manhwaReviewsStateProvider(
                          widget.comic.comicId,
                        ).select((state) => state.user_have_review_before),
                      ),
                      scrollController: _scrollController,
                      reviews: reviews,
                      comic: widget.comic,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
