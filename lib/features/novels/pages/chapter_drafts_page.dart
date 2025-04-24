import 'dart:developer';

import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/features/novels/providers/drafts_state.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/features/novels/widgets/draft_tile.dart';
import 'package:atlas_app/features/novels/widgets/empty_chapters.dart';
import 'package:atlas_app/imports.dart';

class ChapterDraftsPage extends ConsumerStatefulWidget {
  const ChapterDraftsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChapterDraftsPageState();
}

class _ChapterDraftsPageState extends ConsumerState<ChapterDraftsPage> {
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
    final novelId = ref.read(selectedNovelProvider)!.id;
    ref.read(novelChapterDraftsProvider(novelId).notifier).fetchData();
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }

  void refresh() async {
    final novelId = ref.read(selectedNovelProvider)!.id;
    ref.read(novelChapterDraftsProvider(novelId).notifier).fetchData(refresh: true);
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
            appBar: AppBar(title: const Text("المسودات")),
            floatingActionButton:
                isCreator
                    ? FloatingActionButton(
                      backgroundColor: novelColor.withValues(alpha: .6),
                      child: Icon(Icons.add, color: AppColors.whiteColor),

                      onPressed: () {
                        ref.read(selectedDraft.notifier).state = null;
                        context.push(Routes.addNovelChapterPage);
                      },
                    )
                    : null,
            body: AppRefresh(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 400), () => refresh());
              },
              child: Consumer(
                builder: (context, ref, child) {
                  final drafts = ref.watch(
                    novelChapterDraftsProvider(novelId).select((state) => state.drafts),
                  );

                  final loadingMore = ref.watch(
                    novelChapterDraftsProvider(novelId).select((state) => state.isLoading),
                  );

                  final isLoading = ref.watch(
                    novelChapterDraftsProvider(novelId).select((state) => state.isLoading),
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
                                novelChapterDraftsProvider(
                                  novelId,
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
                    child: ListView.builder(
                      cacheExtent: MediaQuery.sizeOf(context).height * 1.5,
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: true,
                      addSemanticIndexes: true,
                      itemCount: drafts.isEmpty ? 1 : drafts.length + (loadingMore ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (drafts.isEmpty) {
                          if (i == 0) {
                            return const EmptyChapters(text: "لايوجد أي مسودات حاليا");
                          }
                          return const SizedBox.shrink();
                        }

                        if (i < drafts.length) {
                          final draft = drafts[i];
                          return DraftTile(key: ValueKey(draft.id), draft: draft);
                        }

                        if (loadingMore && i == drafts.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Loader()),
                          );
                        }

                        return const SizedBox.shrink();
                      },
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
