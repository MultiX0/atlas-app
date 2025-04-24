import 'package:atlas_app/core/common/widgets/cached_avatar.dart';
import 'package:atlas_app/features/profile/controller/profile_controller.dart';
import 'package:atlas_app/features/search/providers/providers.dart';
import 'package:atlas_app/features/search/widgets/empty_search.dart';
import 'package:atlas_app/imports.dart';

class UsersSearch extends ConsumerStatefulWidget {
  const UsersSearch({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UsersSearchState();
}

class _UsersSearchState extends ConsumerState<UsersSearch> {
  @override
  Widget build(BuildContext context) {
    final searchInput = ref.watch(searchQueryProvider);
    final profileSearchRef = ref.watch(searchUsersProvider(searchInput));
    return profileSearchRef.when(
      data: (users) {
        if (users.isEmpty) {
          return const EmptySearch();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          cacheExtent: MediaQuery.sizeOf(context).height * 1.5,
          addRepaintBoundaries: true,
          addSemanticIndexes: true,
          itemCount: users.length,
          itemBuilder: (context, i) {
            final user = users[i];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              // height: 200,
              decoration: BoxDecoration(
                // color: AppColors.gold,
                borderRadius: BorderRadius.circular(Spacing.normalRaduis),
                border: Border.all(
                  color: AppColors.mutedSilver.withValues(alpha: .15),
                  width: 1.25,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 120,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(Spacing.normalRaduis),
                            topRight: Radius.circular(Spacing.normalRaduis),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: user.banner,
                            fit: BoxFit.cover,
                            height: 90,
                            width: double.infinity,
                          ),
                        ),
                        Positioned.fill(
                          child: Material(
                            color: AppColors.scaffoldBackground.withValues(alpha: .25),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          bottom: 0,
                          child: CachedAvatar(avatar: user.avatar, raduis: 35),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "@${user.username}",
                                style: const TextStyle(color: AppColors.mutedSilver, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.whiteColor.withValues(alpha: .85),
                            foregroundColor: AppColors.blackColor,
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                          ),
                          onPressed: () => context.push("${Routes.user}/${user.userId}"),
                          child: const Text(
                            "المزيد",
                            style: TextStyle(fontSize: 16, fontFamily: arabicAccentFont),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      error: (error, _) => Center(child: ErrorWidget(error)),
      loading: () => const Loader(),
    );
  }
}
