import 'dart:developer';

import 'package:atlas_app/core/common/enum/comment_type.dart';
import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/core/common/widgets/error_widget.dart';
import 'package:atlas_app/features/novels/widgets/chapter_comment_input.dart';
import 'package:atlas_app/features/novels/widgets/empty_chapters.dart';
import 'package:atlas_app/features/novels/widgets/reply_status_widget.dart';
import 'package:atlas_app/features/post_comments/providers/comments_state_provider.dart';
import 'package:atlas_app/features/post_comments/providers/providers.dart';
import 'package:atlas_app/features/post_comments/widgets/comment_tile.dart';
import 'package:atlas_app/features/posts/controller/posts_controller.dart';
import 'package:atlas_app/features/posts/providers/post_state.dart';
import 'package:atlas_app/features/profile/provider/providers.dart';
import 'package:atlas_app/features/profile/widgets/post_widget.dart';
import 'package:atlas_app/imports.dart';

class PostPage extends ConsumerStatefulWidget {
  const PostPage({super.key, required this.postId});
  final String postId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> {
  late ScrollController _scrollController;
  final _debouncer = Debouncer();
  bool _mounted = true;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    super.initState();
  }

  DateTime? _lastCheck;
  void _onScroll() {
    if (!_mounted) return;

    final now = DateTime.now();
    if (_lastCheck != null && now.difference(_lastCheck!).inMilliseconds < 500) return;
    _lastCheck = now;

    if (_isBottom) {
      const duration = Duration(milliseconds: 300);
      _debouncer.debounce(
        duration: duration,
        onDebounce: () {
          if (_mounted) {
            ref.read(postCommentsStateProvider(widget.postId).notifier).fetchData();
          }
        },
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    var threshold = MediaQuery.sizeOf(context).height / 4;

    return maxScroll - currentScroll <= threshold;
  }

  @override
  void dispose() {
    _mounted = false;
    _debouncer.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchData({bool refresh = false}) async {
    if (!_mounted) return;

    await Future.microtask(() {
      if (_mounted) {
        ref.read(postCommentsStateProvider(widget.postId).notifier).fetchData(refresh: refresh);
      }
    });
  }

  Future<void> refresh() async {
    if (!_mounted) return;

    try {
      await Future.delayed(const Duration(milliseconds: 400), () async {
        if (_mounted) {
          ref.invalidate(getPostByIDProvider(widget.postId));
          await fetchData(refresh: true);
        }
      });
    } catch (e) {
      log(e.toString());
      if (_mounted) {
        CustomToast.error(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        ref.read(postCommentRepliedToProvider.notifier).state = null;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("المنشور")),
        body: ref
            .watch(getPostByIDProvider(widget.postId))
            .when(
              data: (post) {
                if (_mounted) {
                  fetchData();
                }
                final postLikeType = ref.read(selectedPostLikeTypeProvider);
                log(postLikeType.name);
                return Column(
                  children: [
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, _) {
                          final notifier = postCommentsStateProvider(widget.postId);
                          final comments = ref.watch(notifier.select((s) => s.comments));
                          final isLoading = ref.watch(notifier.select((s) => s.isLoading));
                          final loadingMore = ref.watch(notifier.select((s) => s.loadingMore));
                          int itemCount =
                              isLoading
                                  ? 2
                                  : (comments.isEmpty || !post.comments_open)
                                  ? 2
                                  : // Post + empty state
                                  comments.length +
                                      1 +
                                      (loadingMore ? 1 : 0); // Post + comments + optional loader

                          return AppRefresh(
                            onRefresh: refresh,
                            child: Align(
                              child: ListView.builder(
                                addRepaintBoundaries: true,
                                cacheExtent: MediaQuery.sizeOf(context).height,
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                itemCount: itemCount,
                                itemBuilder: (context, i) {
                                  if (i == 0) {
                                    final _post = ref.watch(postStateProvider);
                                    return PostWidget(
                                      post: _post ?? post,
                                      onShare: () => CustomToast.soon(),
                                      postLikeType: postLikeType,
                                    );
                                  }
                                  if (isLoading) return const Loader();

                                  if (!post.comments_open) {
                                    return const EmptyChapters(text: "التعليقات مغلقة");
                                  }

                                  if (comments.isEmpty) {
                                    return const EmptyChapters(text: "لايوجد أي تعليقات حاليا");
                                  }
                                  if (loadingMore && i == comments.length + 1) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(child: Loader()),
                                    );
                                  }

                                  final comment = comments.elementAt(i - 1);
                                  return PostCommentTile(
                                    postCreator: post.userId,
                                    key: ValueKey(comment.id),
                                    comment: comment,
                                    postId: post.postId,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (post.comments_open) ...[
                      Divider(height: 0.35, color: AppColors.mutedSilver.withValues(alpha: .15)),
                      const ReplyStatusWidget(commentType: CommentType.post),
                      const ChaptersCommentInput(commentType: CommentType.post),
                    ],
                  ],
                );
              },
              error: (error, _) => AtlasErrorPage(message: error.toString()),
              loading: () => const Loader(),
            ),
      ),
    );
  }
}
