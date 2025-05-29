import 'dart:async';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/error_widget.dart';
import 'package:atlas_app/core/common/widgets/reuseable_comment_widget.dart';
import 'package:atlas_app/features/dashs/controller/dashs_controller.dart';
import 'package:atlas_app/features/dashs/providers/dash_page_state.dart';
import 'package:atlas_app/features/dashs/widgets/dash_image.dart';
import 'package:atlas_app/features/dashs/widgets/dash_user_card.dart';
import 'package:atlas_app/features/dashs/widgets/dashs_appbar.dart';
import 'package:atlas_app/features/novels/widgets/empty_chapters.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

final _isScrolling = StateProvider.autoDispose<bool>((ref) {
  return false;
});

class DashPage extends ConsumerStatefulWidget {
  const DashPage({super.key, required this.dashId});

  final String dashId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashPageState();
}

class _DashPageState extends ConsumerState<DashPage> {
  final _scrollController = ScrollController();
  Timer? _scrollTimer;
  Timer? _timeSpentTimer;
  final Debouncer _debouncer = Debouncer();
  int currentTime = -5;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchDash());
    _timeSpentTimer = Timer.periodic((const Duration(seconds: 1)), (_) {
      currentTime++;
      if (currentTime > 0 && currentTime % 2 == 0) {
        updateInteractions(currentTime);
      }
    });
  }

  void fetchDash({bool refresh = false}) {
    ref.read(dashPageStateProvider(widget.dashId).notifier).fetchDash(refresh: refresh);
  }

  void updateInteractions(int time) {
    ref
        .read(dashsControllerProvider.notifier)
        .upsertDashInteraction(dashId: widget.dashId, timeSpent: time);
  }

  void _scrollListener() {
    _scrollTimer?.cancel();

    if (!ref.read(_isScrolling)) {
      ref.read(_isScrolling.notifier).state = true;
    }

    _scrollTimer = Timer(const Duration(milliseconds: 600), () {
      ref.read(_isScrolling.notifier).state = false;
    });
  }

  DateTime? _lastCheck;
  void _onScroll() {
    final now = DateTime.now();
    if (_lastCheck != null && now.difference(_lastCheck!).inMilliseconds < 500) return;
    _lastCheck = now;
    if (_isAtSeventyPercent) {
      const duration = Duration(milliseconds: 500);
      _debouncer.debounce(
        duration: duration,
        onDebounce: () {
          ref
              .read(dashPageStateProvider(widget.dashId).notifier)
              .fetchDash(refresh: false, loadMore: true);
        },
      );
    }
  }

  bool get _isAtSeventyPercent {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    // Calculate 70% of the total scrollable content
    final seventyPercentThreshold = maxScroll * 0.7;

    return currentScroll >= seventyPercentThreshold;
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollTimer?.cancel();
    _timeSpentTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * .75;
    return SafeArea(
      child: Scaffold(
        appBar: DashsAppBar(
          provider: _isScrolling,
          keyValue: 'dash-page-appbar',
          title: '',
          actions: [
            IconButton(
              onPressed: () => CustomToast.soon(),
              icon: Icon(Icons.more_vert, color: AppColors.whiteColor),
            ),
          ],
        ),
        body: RepaintBoundary(
          child: Consumer(
            builder: (context, ref, child) {
              final provider = dashPageStateProvider(widget.dashId);
              final isLoading = ref.watch(provider.select((s) => s.isLoading));
              if (isLoading) return child!;
              final error = ref.watch(provider.select((s) => s.error));
              if (error != null) return AtlasErrorPage(message: error.toString());
              final dash = ref.watch(provider.select((s) => s.dash));
              if (dash == null) {
                return const AtlasErrorPage(message: 'current dash has value of null');
              }
              final recommendations = ref.watch(provider.select((s) => s.recommendations));
              final loadingMore = ref.watch(provider.select((s) => s.loadingMore));

              return ListView(
                controller: _scrollController,
                addRepaintBoundaries: true,
                addSemanticIndexes: true,
                cacheExtent: MediaQuery.sizeOf(context).height,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxHeight,
                      minWidth: MediaQuery.sizeOf(context).width,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: dash.image,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[800]!,
                            highlightColor: Colors.grey[400]!,
                            child: Container(color: Colors.grey[600]),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[600],
                            child: const Icon(Icons.broken_image),
                          ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  DashUserCard(dash: dash),
                  if (dash.content != null && dash.content!.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    RepaintBoundary(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: CommentRichTextView(
                            text: dash.content!,
                            style: const TextStyle(fontFamily: arabicAccentFont, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 5),

                  if (recommendations.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 16.0, bottom: 8),
                      child: Text(
                        textDirection: TextDirection.rtl,
                        "اقتراحات مشابهة",
                        style: TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
                      ),
                    ),
                    MasonryGridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      key: const Key('recommendation-dashs-list'),
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      cacheExtent: MediaQuery.sizeOf(context).height,
                      addRepaintBoundaries: true,
                      itemCount:
                          recommendations.isEmpty
                              ? 1
                              : recommendations.length + (loadingMore ? 1 : 0),
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (recommendations.isEmpty) ? 1 : 2,
                      ),
                      itemBuilder: (context, i) {
                        if (recommendations.isEmpty && i == 0) {
                          return const EmptyChapters(text: "لايوجد هنالك محتوى");
                        }

                        if (i == recommendations.length && loadingMore) {
                          return const Loader();
                        }
                        final dash = recommendations[i];
                        return GestureDetector(
                          onTap: () => context.push("${Routes.dashPage}/${dash.id}"),
                          child: SimpleDynamicImage(imageUrl: dash.image, imageId: dash.id),
                        );
                      },
                    ),
                  ],
                ],
              );
            },
            child: const Loader(),
          ),
        ),
      ),
    );
  }
}
