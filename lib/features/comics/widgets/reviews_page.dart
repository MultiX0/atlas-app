import 'package:atlas_app/core/common/widgets/loader.dart';
import 'package:atlas_app/features/comics/models/comic_model.dart';
import 'package:atlas_app/features/comics/providers/manhwa_reviews_state.dart';
import 'package:atlas_app/features/comics/widgets/reviews_widget.dart';
import 'package:atlas_app/features/navs/navs.dart';
import 'package:atlas_app/features/reviews/controller/reviews_controller.dart';
import 'package:atlas_app/imports.dart';

class ComicReviewsPage extends ConsumerStatefulWidget {
  const ComicReviewsPage({super.key, required this.comic});

  final ComicModel comic;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends ConsumerState<ComicReviewsPage> {
  final ScrollController _scrollController = ScrollController();
  bool fetched = false;
  int? reviewsCount;
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
      ref.read(manhwaReviewsStateProvider(widget.comic.comicId).notifier).fetchReviews();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Load more when we're 200 pixels from the bottom
    return currentScroll >= (maxScroll - 200);
  }

  void fetchData() async {
    ref.read(manhwaReviewsStateProvider(widget.comic.comicId).notifier).fetchReviews();
    final _count = await ref
        .read(reviewsControllerProvider.notifier)
        .getManhwaReviewsCount(widget.comic.comicId);
    setState(() {
      fetched = true;
      reviewsCount = _count;
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

  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(manhwaReviewsStateProvider(widget.comic.comicId));
    final reviews = reviewsState.reviews;
    final color = widget.comic.color != null ? HexColor(widget.comic.color!) : AppColors.primary;

    if (reviewsState.isLoading) {
      return const Loader();
    }

    Color getFontColorForBackground() {
      return (color.computeLuminance() > 0.128) ? Colors.black : Colors.white;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(navsProvider).goToAddComicReviewPage(),
        backgroundColor: color,
        tooltip: "اضافة مراجعة",
        child: Icon(TablerIcons.edit, color: getFontColorForBackground()),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 10),
                  ReviewsWidget(reviews: reviews, comic: widget.comic),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
