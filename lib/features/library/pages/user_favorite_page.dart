import 'dart:developer';

import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/features/library/providers/my_favorite_state.dart';
import 'package:atlas_app/features/library/widgets/work_poster.dart';
import 'package:atlas_app/imports.dart';

class UserFavoritePage extends ConsumerStatefulWidget {
  final String userId;
  const UserFavoritePage({super.key, required this.userId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyWorkState();
}

class _MyWorkState extends ConsumerState<UserFavoritePage> {
  bool fetched = false;
  final Debouncer _debouncer = Debouncer();
  double _previousScroll = 0.0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!fetched) {
        fetchData();
      }
    });
    super.initState();
  }

  void fetchData() async {
    await Future.microtask(() {
      ref.read(userFavoriteState(widget.userId).notifier).fetchData();
      setState(() {
        fetched = true;
      });
    });
  }

  void refresh() async {
    await Future.delayed(const Duration(milliseconds: 400), () {
      ref.read(userFavoriteState(widget.userId).notifier).fetchData(refresh: true);
    });
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, _) {
          final works = ref.watch(userFavoriteState(widget.userId).select((state) => state.works));
          final isLoading = ref.watch(
            userFavoriteState(widget.userId).select((state) => state.isLoading),
          );
          final loadingMore = ref.watch(
            userFavoriteState(widget.userId).select((state) => state.loadingMore),
          );

          if (isLoading) {
            return const Loader();
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                final metrics = scrollNotification.metrics;
                final maxScroll = metrics.maxScrollExtent;
                final currentScroll = metrics.pixels;
                const delta = 200.0;

                if (currentScroll > _previousScroll + 10 && maxScroll - currentScroll <= delta) {
                  log("Near bottom, triggering fetch");
                  const duration = Duration(milliseconds: 500);
                  _debouncer.debounce(
                    duration: duration,
                    onDebounce: () {
                      ref.read(userFavoriteState(widget.userId).notifier).fetchData();
                    },
                  );
                }
                _previousScroll = currentScroll;
              }
              return false;
            },
            child: AppRefresh(
              onRefresh: () async => refresh(),
              child: Align(
                child: GridView.builder(
                  shrinkWrap: works.isEmpty,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  itemCount: works.isEmpty ? 1 : works.length + (loadingMore ? 1 : 0),
                  padding: const EdgeInsets.fromLTRB(13, 15, 13, 15),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: works.isEmpty ? 1 : 3,
                    childAspectRatio: works.isEmpty ? 1 : 1 / 1.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, i) {
                    if (works.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/no_data_cry_.gif', height: 130),
                            const SizedBox(height: 15),
                            const Text(
                              "لايوجد شيء في المفضلة",
                              style: TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
                            ),
                          ],
                        ),
                      );
                    }
                    if (loadingMore && i == works.length) {
                      return const Center(child: Loader());
                    }
                    final work = works[i];
                    return WorkPoster(work: work);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
