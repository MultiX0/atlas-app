import 'dart:async';

import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/core/common/widgets/error_widget.dart';
import 'package:atlas_app/features/dashs/providers/dashs_state_provider.dart';
import 'package:atlas_app/features/dashs/widgets/dashs_action_button.dart';
import 'package:atlas_app/features/dashs/widgets/dashs_appbar.dart';
import 'package:atlas_app/features/dashs/widgets/dashs_loading.dart';
import 'package:atlas_app/features/novels/widgets/empty_chapters.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

final _isScrolling = StateProvider<bool>((ref) {
  return false;
});

class DashsPage extends ConsumerStatefulWidget {
  const DashsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashsPageState();
}

class _DashsPageState extends ConsumerState<DashsPage> {
  final ScrollController _scrollController = ScrollController();
  bool fetched = false;
  final Debouncer _debouncer = Debouncer();
  String userId = '';
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!fetched) {
        fetchData();
      }
      _scrollController.addListener(_onScroll);
      _scrollController.addListener(_scrollListener);
    });
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
    if (_isBottom) {
      const duration = Duration(milliseconds: 500);
      _debouncer.debounce(
        duration: duration,
        onDebounce: () {
          ref.read(dashsStateProvider(userId).notifier).fetchData();
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
      ref.read(dashsStateProvider(me.userId).notifier).fetchData();

      setState(() {
        fetched = true;
      });
    });
  }

  void refresh() async {
    await Future.delayed(const Duration(milliseconds: 400), () {
      ref.read(dashsStateProvider(userId).notifier).fetchData(refresh: true);
    });
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: DashsAppBar(provider: _isScrolling),
        floatingActionButton: DashsActionButton(provider: _isScrolling),

        body: Consumer(
          builder: (context, ref, child) {
            final dashs = ref.watch(dashsStateProvider(userId).select((s) => s.dashs));
            final isLoading = ref.watch(dashsStateProvider(userId).select((s) => s.isLoading));
            final loadingMore = ref.watch(dashsStateProvider(userId).select((s) => s.loadingMore));
            final error = ref.watch(dashsStateProvider(userId).select((s) => s.error));

            if (isLoading) return child!;
            if (error != null) return AtlasErrorPage(message: error.toString());

            return AppRefresh(
              onRefresh: () async => refresh(),
              child: Align(
                alignment: Alignment.center,
                child: MasonryGridView.builder(
                  controller: _scrollController,
                  key: const Key('dashs-list'),
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  cacheExtent: MediaQuery.sizeOf(context).height,
                  addRepaintBoundaries: true,
                  itemCount: dashs.isEmpty ? 1 : dashs.length + (loadingMore ? 1 : 0),
                  shrinkWrap: (dashs.isEmpty),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (dashs.isEmpty) ? 1 : 2,
                  ),
                  itemBuilder: (context, i) {
                    if (dashs.isEmpty && i == 0) {
                      return const EmptyChapters(text: "لايوجد هنالك محتوى");
                    }

                    if (i == dashs.length && loadingMore) {
                      return const Loader();
                    }
                    final dash = dashs[i];
                    return ClipRRect(
                      key: ValueKey(dash.id),
                      borderRadius: BorderRadius.circular(15),
                      child: Image(
                        image: CachedNetworkImageProvider(dash.image),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            );
          },
          child: const MasonryShimmerLoading(),
        ),
      ),
    );
  }
}
