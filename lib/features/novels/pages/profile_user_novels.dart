import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/features/explore/widgets/explore_card.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/widgets/empty_chapters.dart';
import 'package:atlas_app/imports.dart';

class ProfileUserNovels extends ConsumerWidget {
  const ProfileUserNovels({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final novelsRef = ref.watch(getUserNovelsProvider(userId));
    return novelsRef.when(
      data: (novels) {
        return AppRefresh(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 300), () {
              ref.invalidate(getUserNovelsProvider(userId));
            });
          },
          child: Align(
            child: ListView.builder(
              shrinkWrap: novels.isEmpty,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
              cacheExtent: MediaQuery.sizeOf(context).height * 1.5,
              addRepaintBoundaries: true,
              addSemanticIndexes: true,
              itemCount: novels.isEmpty ? 1 : novels.length,
              itemBuilder: (context, i) {
                if (novels.isEmpty && i == 0) {
                  return const EmptyChapters(text: "لايوجد هنالك محتوى");
                }

                final novel = novels[i];
                return ExploreCard(
                  key: ValueKey(novel.id),
                  color: novel.color,
                  id: novel.id,
                  onTap: () => context.push("${Routes.novelPage}/${novel.id}"),
                  poster: novel.poster,
                  title: novel.title,
                  banner: novel.banner.isEmpty ? null : novel.banner,
                  description: novel.description,
                );
              },
            ),
          ),
        );
      },
      error: (error, _) => Center(child: ErrorWidget(error)),
      loading: () => const Loader(),
    );
  }
}
