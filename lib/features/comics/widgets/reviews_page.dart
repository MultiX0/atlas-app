import 'package:atlas_app/core/common/enum/reviews_enum.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/imports.dart';

class ComicReviewsPage extends ConsumerStatefulWidget {
  const ComicReviewsPage({super.key, required this.comic});

  final ComicModel comic;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends ConsumerState<ComicReviewsPage> {
  late final Color color;
  late final Color fontColorForBackground;
  bool fetched = false;
  int? reviewsCount;
  bool hideFloating = false;
  double _previousScroll = 0.0;

  @override
  void initState() {
    color = widget.comic.color != null ? HexColor(widget.comic.color!) : AppColors.primary;
    fontColorForBackground = (color.computeLuminance() > 0.128) ? Colors.black : Colors.white;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!fetched) {
        fetchData();
      }
    });
    super.initState();
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

  void addReview(List<ComicReviewModel> reviews, bool iAlreadyReviewdOnce) {
    if (reviews.isEmpty || !iAlreadyReviewdOnce) {
      ref.read(navsProvider).goToAddReviewPage('f', ReviewsEnum.comic);
    } else {
      ref.read(navsProvider).goToMakePostPage(PostType.comic);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                final metrics = scrollNotification.metrics;
                final maxScroll = metrics.maxScrollExtent;
                final currentScroll = metrics.pixels;
                const delta = 100.0;

                if (currentScroll > _previousScroll && maxScroll - currentScroll <= delta) {
                  ref
                      .read(manhwaReviewsStateProvider(widget.comic.comicId).notifier)
                      .fetchReviews();
                }
                _previousScroll = currentScroll;
              }
              return false;
            },
            child: CustomScrollView(
              cacheExtent: MediaQuery.sizeOf(context).height * 1.5,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.normal),
              ),
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
      ),
    );
  }
}
