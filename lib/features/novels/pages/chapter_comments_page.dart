import 'dart:developer';

import 'package:atlas_app/core/common/enum/comment_type.dart';
import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/features/novels/providers/chapter_comments_state.dart';
import 'package:atlas_app/features/novels/providers/chapter_state.dart';
import 'package:atlas_app/features/novels/widgets/chapter_comment_input.dart';
import 'package:atlas_app/features/novels/widgets/chapter_comment_tile.dart';
import 'package:atlas_app/features/novels/widgets/empty_chapters.dart';
import 'package:atlas_app/features/novels/widgets/reply_status_widget.dart';
import 'package:atlas_app/imports.dart';

class ChapterCommentsPage extends ConsumerStatefulWidget {
  const ChapterCommentsPage({super.key, required this.chapterId});

  final String chapterId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChapterCommentsPageState();
}

class _ChapterCommentsPageState extends ConsumerState<ChapterCommentsPage> {
  late ScrollController _scrollController;
  final _debouncer = Debouncer();

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
    super.initState();
  }

  DateTime? _lastCheck;
  void _onScroll() {
    final now = DateTime.now();
    if (_lastCheck != null && now.difference(_lastCheck!).inMilliseconds < 500) return;
    _lastCheck = now;
    if (_isBottom) {
      const duration = Duration(milliseconds: 500);
      _debouncer.debounce(
        duration: duration,
        onDebounce: () {
          ref.read(novelChapterCommentsStateProvider(widget.chapterId).notifier).fetchData();
        },
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    var threshold = MediaQuery.sizeOf(context).height / 2;

    return maxScroll - currentScroll <= threshold;
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _scrollController.dispose();
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  Future<void> fetchData({bool refresh = false}) async {
    await Future.microtask(() async {
      await ref
          .read(novelChapterCommentsStateProvider(widget.chapterId).notifier)
          .fetchData(refresh: refresh);
    });
  }

  Future<void> refresh() async {
    try {
      await Future.delayed(const Duration(milliseconds: 400), () async {
        await fetchData(refresh: true);
      });
    } catch (e) {
      log(e.toString());
      CustomToast.error(errorMsg);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, _) {
            final chapter = ref.read(chapterStateProvider(widget.chapterId)).chapter!;
            final text = chapter.title ?? "فصل رقم: ${chapter.number.toInt()}";
            return Text(text);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final chapter = ref.read(chapterStateProvider(widget.chapterId)).chapter!;
                final notifier = novelChapterCommentsStateProvider(chapter.id);
                final comments = ref.watch(notifier.select((s) => s.comments));
                final isLoading = ref.watch(notifier.select((s) => s.isLoading));
                final loadingMore = ref.watch(notifier.select((s) => s.loadingMore));

                if (isLoading) return const Loader();

                return AppRefresh(
                  onRefresh: refresh,
                  child: Align(
                    child: ListView.builder(
                      shrinkWrap: comments.isEmpty,
                      addRepaintBoundaries: true,
                      cacheExtent: MediaQuery.sizeOf(context).height * 1.5,
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      itemCount: comments.isEmpty ? 1 : comments.length + (loadingMore ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (comments.isEmpty) {
                          if (i == 0) {
                            return const EmptyChapters(text: "لايوجد أي تعليقات حاليا");
                          }
                          return const SizedBox.shrink();
                        }
                        if (loadingMore && i == comments.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Loader()),
                          );
                        }
                        final comment = comments[i];
                        return ChapterCommentTile(
                          key: ValueKey(comment.id),
                          comment: comment,
                          chapterId: comment.chapterId,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          Divider(height: 0.35, color: AppColors.mutedSilver.withValues(alpha: .15)),
          const ReplyStatusWidget(commentType: CommentType.novel),
          ChaptersCommentInput(commentType: CommentType.novel, chapterId: widget.chapterId),
        ],
      ),
    );
  }
}
