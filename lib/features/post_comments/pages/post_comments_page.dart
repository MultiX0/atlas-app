import 'package:atlas_app/core/common/enum/comment_type.dart';
import 'package:atlas_app/features/post_comments/providers/comments_state_provider.dart';
import 'package:atlas_app/features/post_comments/widgets/comment_tile.dart';
import 'package:atlas_app/imports.dart';

import 'dart:developer';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/features/novels/widgets/chapter_comment_input.dart';
import 'package:atlas_app/features/novels/widgets/empty_chapters.dart';
import 'package:atlas_app/features/novels/widgets/reply_status_widget.dart';

class PostCommentsPage extends ConsumerStatefulWidget {
  const PostCommentsPage({super.key, required this.postId, required this.withAppBar});

  final String postId;
  final bool withAppBar;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostCommentsPageState();
}

class _PostCommentsPageState extends ConsumerState<PostCommentsPage> {
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
      const duration = Duration(milliseconds: 300);
      _debouncer.debounce(
        duration: duration,
        onDebounce: () {
          ref.read(postCommentsStateProvider(widget.postId).notifier).fetchData();
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
    await Future.microtask(() {
      ref.read(postCommentsStateProvider(widget.postId).notifier).fetchData(refresh: refresh);
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
      appBar: widget.withAppBar ? AppBar(title: const Text("التعليقات")) : null,
      body: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final notifier = postCommentsStateProvider(widget.postId);
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
                      cacheExtent: MediaQuery.sizeOf(context).height,
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
                        return PostCommentTile(
                          key: ValueKey(comment.id),
                          postCreator: '',
                          comment: comment,
                          postId: comment.postId,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          Divider(height: 0.35, color: AppColors.mutedSilver.withValues(alpha: .15)),
          const ReplyStatusWidget(commentType: CommentType.post),
          const ChaptersCommentInput(commentType: CommentType.post),
        ],
      ),
    );
  }
}
