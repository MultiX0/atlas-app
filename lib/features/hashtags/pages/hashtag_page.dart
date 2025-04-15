import 'dart:developer';

import 'package:atlas_app/core/common/enum/hashtag_enum.dart';
import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/utils/debouncer/throttler.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/features/hashtags/providers/hashtag_state_provider.dart';
import 'package:atlas_app/features/hashtags/widgets/hashtag_body.dart';
import 'package:atlas_app/features/hashtags/widgets/hashtags_header.dart';
import 'package:atlas_app/imports.dart';

class HashtagPage extends ConsumerStatefulWidget {
  const HashtagPage({super.key, required this.hashtag});
  final String hashtag;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HashtagPageState();
}

class _HashtagPageState extends ConsumerState<HashtagPage> {
  late ScrollController _scrollController;
  final Debouncer _debouncer = Debouncer();
  final Throttler _throttle = Throttler();

  @override
  void initState() {
    initialFetch();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScrollListener);
    super.initState();
  }

  void initialFetch() async {
    Future.microtask(fetch);
  }

  void fetch() {
    ref.read(hashtagStateProvider(widget.hashtag).notifier).fetchData();
  }

  double _previousScroll = 0.0;
  DateTime? _lastCheck;
  HashtagFilter _currentFilter = HashtagFilter.LAST_CREATED;

  void _onScrollListener() {
    final now = DateTime.now();
    if (_lastCheck != null && now.difference(_lastCheck!).inMilliseconds < 500) {
      return;
    }
    _lastCheck = now;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const delta = 200.0;

    if (currentScroll > _previousScroll + 10 && maxScroll - currentScroll <= delta) {
      log("Near bottom, triggering fetch");
      const duration = Duration(milliseconds: 500);
      _debouncer.debounce(
        duration: duration,
        onDebounce: () {
          final state = ref.read(hashtagStateProvider(widget.hashtag));
          if (!state.hasReachedEnd) {
            fetch();
          } else {
            log("No more data to fetch (hasReachedEnd)");
          }
        },
      );
    }

    _previousScroll = currentScroll;
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _throttle.cancel();
    _scrollController.removeListener(_onScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void refresh({HashtagFilter? filter}) async {
    if (filter != null) {
      if (filter != _currentFilter) {
        ref
            .read(hashtagStateProvider(widget.hashtag).notifier)
            .fetchData(refresh: true, filter: filter);
        setState(() {
          _currentFilter = filter;
        });
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 800), () async {
        ref.read(hashtagStateProvider(widget.hashtag).notifier).fetchData(refresh: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(hashtagStateProvider(widget.hashtag));
            if (state.isLoading && state.posts.isEmpty) {
              return child!;
            }

            if (state.error != null) {
              log('Error state: ${state.error}');
              return buildError(state, ref);
            }

            return AppRefresh(
              onRefresh: () async => refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.normal),
                ),
                cacheExtent: MediaQuery.sizeOf(context).height * 1.5,
                controller: _scrollController,
                slivers: [
                  HashtagsHeader(
                    hashtag: state.hashtag!.hashtag,
                    postCount: state.hashtag!.postCount,
                  ),
                  if (state.isLoading) ...[
                    const SliverFillRemaining(child: Loader()),
                  ] else ...[
                    HashtagsBody(
                      currentFilter: _currentFilter,
                      posts: state.posts,
                      loadingMore: state.loadingMore,
                      updateFilter: (f) {
                        refresh(filter: f);
                      },
                    ),
                  ],
                ],
              ),
            );
          },
          child: const Center(child: Loader()),
        ),
      ),
    );
  }

  Center buildError(HashtagStateHelper state, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: ${state.error}'),
          ElevatedButton(
            onPressed: () {
              debugPrint('Retry fetch triggered');
              ref.read(hashtagStateProvider(widget.hashtag).notifier).fetchData(refresh: true);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
