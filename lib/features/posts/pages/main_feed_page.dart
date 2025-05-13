import 'dart:async';

import 'package:atlas_app/core/common/enum/post_like_enum.dart';
import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/features/novels/widgets/empty_chapters.dart';
import 'package:atlas_app/features/posts/db/posts_db.dart';
import 'package:atlas_app/features/posts/providers/main_feed_state.dart';
import 'package:atlas_app/features/posts/widgets/main_feed_appbar.dart';
import 'package:atlas_app/features/profile/widgets/post_widget.dart';
import 'package:atlas_app/imports.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    var threshold = MediaQuery.sizeOf(context).height / 2;

    return maxScroll - currentScroll <= threshold;
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

  Timer? _seenTimer;
  final Set<String> _alreadyMarkedSeen = {};
  void _onVisible(double visibleFraction, String postId) {
    // Mark as seen only if more than 60% visible and not already marked
    if (!_alreadyMarkedSeen.contains(postId) && visibleFraction > 0.6) {
      _seenTimer?.cancel();
      _seenTimer = Timer(const Duration(milliseconds: 500), () {
        ref.read(postsDbProvider).seePost(postId, userId);
        _alreadyMarkedSeen.add(postId);
      });
    } else if (visibleFraction <= 0.6) {
      _seenTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _seenTimer?.cancel();
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
          cacheExtent: MediaQuery.sizeOf(context).height,
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
                  return VisibilityDetector(
                    key: ValueKey(post.postId),
                    onVisibilityChanged: (info) {
                      final visibleFraction = info.visibleFraction;
                      _onVisible(visibleFraction, post.postId);
                    },

                    child: PostWidget(
                      key: ValueKey(post.postId),
                      post: post,
                      onShare: () => CustomToast.soon(),
                      postLikeType: PostLikeEnum.GENERAL,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
