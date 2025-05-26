import 'dart:developer';

import 'package:atlas_app/core/common/enum/post_like_enum.dart';
import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/core/common/widgets/general_loading.dart';
import 'package:atlas_app/features/auth/controller/auth_controller.dart';
import 'package:atlas_app/features/profile/controller/profile_controller.dart';
import 'package:atlas_app/features/profile/provider/profile_posts_state.dart';
import 'package:atlas_app/features/profile/widgets/post_widget.dart';
import 'package:atlas_app/imports.dart';

class ProfilePostsPage extends ConsumerStatefulWidget {
  const ProfilePostsPage({super.key, required this.user});

  final UserModel user;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePostsPageState();
}

class _ProfilePostsPageState extends ConsumerState<ProfilePostsPage> {
  final Debouncer _debouncer = Debouncer();

  @override
  void initState() {
    initialFetch();
    super.initState();
  }

  void initialFetch() async {
    Future.microtask(fetch);
  }

  void fetch() {
    ref.read(profilePostsStateProvider(widget.user.userId).notifier).fetchData();
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }

  void refresh() async {
    final me = ref.read(userState.select((s) => s.user!));
    ref.read(profilePostsStateProvider(widget.user.userId).notifier).fetchData(refresh: true);
    if (widget.user.userId != me.userId) {
      ref.invalidate(getUserByIdProvider(widget.user.userId));
    } else {
      final userData = await ref.read(authControllerProvider.notifier).getUserData(me.userId);
      ref.read(userState.notifier).updateState(userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AppRefresh(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 400), () => refresh());
        },
        child: Consumer(
          builder: (context, ref, child) {
            final posts = ref.watch(
              profilePostsStateProvider(widget.user.userId).select((state) => state.posts),
            );

            final loadingMore = ref.watch(
              profilePostsStateProvider(widget.user.userId).select((state) => state.isLoading),
            );

            final isLoading = ref.watch(
              profilePostsStateProvider(widget.user.userId).select((state) => state.isLoading),
            );
            if (isLoading) return child!;

            return NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification) {
                  final metrics = scrollNotification.metrics;
                  final maxScroll = metrics.maxScrollExtent;
                  final currentScroll = metrics.pixels;
                  var threshold = MediaQuery.sizeOf(context).height / 2;

                  if (maxScroll - currentScroll <= threshold) {
                    log("Near bottom, triggering fetch");
                    const duration = Duration(milliseconds: 500);
                    _debouncer.debounce(
                      duration: duration,
                      onDebounce: () {
                        final state = ref.read(profilePostsStateProvider(widget.user.userId));
                        if (!state.hasReachedEnd) {
                          fetch();
                        } else {
                          log("No more data to fetch (hasReachedEnd)");
                        }
                      },
                    );
                  }
                }
                return false;
              },
              child: Align(
                child: ListView.builder(
                  addAutomaticKeepAlives: true,
                  addRepaintBoundaries: true,
                  addSemanticIndexes: true,
                  shrinkWrap: posts.isEmpty,
                  itemCount: posts.isEmpty ? 1 : posts.length + (loadingMore ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (posts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/no_data_cry_.gif', height: 130),
                            const SizedBox(height: 15),
                            const Text(
                              "ليس لديك أي منشور!",
                              style: TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
                            ),
                          ],
                        ),
                      );
                    }

                    if (loadingMore && i == posts.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Loader()),
                      );
                    }

                    final post = posts[i];
                    return PostWidget(
                      key: ValueKey(post.postId),
                      profileNav: false,
                      post: post,
                      postLikeType: PostLikeEnum.PROFILE,
                      onShare: () => CustomToast.soon(),
                    );
                  },
                ),
              ),
            );
          },
          child: const GeneralLoading(),
        ),
      ),
    );
  }
}
