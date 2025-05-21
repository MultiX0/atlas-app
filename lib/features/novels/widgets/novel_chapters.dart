import 'dart:developer';

import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/features/novels/providers/chapters_state.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/features/novels/widgets/chapter_tile.dart';
import 'package:atlas_app/features/novels/widgets/draft_chapters_tile.dart';
import 'package:atlas_app/features/novels/widgets/empty_chapters.dart';
import 'package:atlas_app/imports.dart';

class NovelChapters extends ConsumerStatefulWidget {
  const NovelChapters({super.key, required this.novelId});
  final String novelId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NovelChaptersState();
}

class _NovelChaptersState extends ConsumerState<NovelChapters> {
  final Debouncer _debouncer = Debouncer();
  double _previousScroll = 0.0;

  @override
  void initState() {
    initialFetch();
    super.initState();
  }

  void initialFetch() async {
    Future.microtask(fetch);
  }

  void fetch() {
    ref.read(chaptersStateProvider(widget.novelId).notifier).fetchData();
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }

  void refresh() async {
    ref.read(chaptersStateProvider(widget.novelId).notifier).fetchData(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Consumer(
        builder: (context, ref, _) {
          final novelCreator = ref.read(selectedNovelProvider.select((s) => s!.userId));
          final novelColor = ref.read(selectedNovelProvider.select((s) => s!.color));
          final novelId = ref.read(selectedNovelProvider.select((s) => s!.id));

          final me = ref.read(userState.select((s) => s.user!.userId));
          bool isCreator = me == novelCreator;
          return Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton:
                isCreator
                    ? FloatingActionButton(
                      backgroundColor: novelColor.withValues(alpha: .6),
                      child: Icon(Icons.add, color: AppColors.whiteColor),

                      onPressed: () {
                        ref.read(selectedDraft.notifier).state = null;
                        context.push("${Routes.addNovelChapterPage}/$novelId");
                      },
                    )
                    : null,
            body: AppRefresh(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 400), () => refresh());
              },
              child: Consumer(
                builder: (context, ref, child) {
                  final chapters = ref.watch(
                    chaptersStateProvider(widget.novelId).select((state) => state.chapters),
                  );

                  final loadingMore = ref.watch(
                    chaptersStateProvider(widget.novelId).select((state) => state.isLoading),
                  );

                  final isLoading = ref.watch(
                    chaptersStateProvider(widget.novelId).select((state) => state.isLoading),
                  );
                  if (isLoading) return child!;

                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollUpdateNotification) {
                        final metrics = scrollNotification.metrics;
                        final maxScroll = metrics.maxScrollExtent;
                        final currentScroll = metrics.pixels;
                        const delta = 200.0;

                        if (currentScroll > _previousScroll + 10 &&
                            maxScroll - currentScroll <= delta) {
                          log("Near bottom, triggering fetch");
                          const duration = Duration(milliseconds: 500);
                          _debouncer.debounce(
                            duration: duration,
                            onDebounce: () {
                              final hasReachedEnd = ref.read(
                                chaptersStateProvider(
                                  widget.novelId,
                                ).select((state) => state.hasReachedEnd),
                              );
                              if (!hasReachedEnd) {
                                fetch();
                              } else {
                                log("No more data to fetch (hasReachedEnd)");
                              }
                            },
                          );
                        }
                        _previousScroll = currentScroll;
                      }
                      return false;
                    },
                    child: CustomScrollView(
                      cacheExtent: MediaQuery.sizeOf(context).height * 1.5,
                      slivers: [
                        SliverOverlapInjector(
                          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                        ),
                        SliverList.builder(
                          addAutomaticKeepAlives: true,
                          addRepaintBoundaries: true,
                          addSemanticIndexes: true,
                          itemCount:
                              chapters.isEmpty
                                  ? (isCreator ? 2 : 1)
                                  : chapters.length + (loadingMore ? 1 : 0) + (isCreator ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (isCreator && i == 0) {
                              return const ChaptersDraftTile();
                            }

                            final adjustedIndex = isCreator ? i - 1 : i;

                            if (chapters.isEmpty) {
                              if (adjustedIndex == 0) {
                                return const EmptyChapters(text: "لايوجد أي فصول حاليا");
                              }
                              return const SizedBox.shrink();
                            }

                            if (adjustedIndex < chapters.length) {
                              final chapter = chapters[adjustedIndex];
                              return ChapterTile(
                                key: ValueKey(chapter.id),
                                chapter: chapter,
                                isCreator: isCreator,
                              );
                            }

                            if (loadingMore && adjustedIndex == chapters.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: Loader()),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: const Loader(),
              ),
            ),
          );
        },
      ),
    );
  }
}
