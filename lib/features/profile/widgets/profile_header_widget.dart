import 'package:atlas_app/core/common/widgets/app_refresh.dart';
import 'package:atlas_app/features/profile/controller/profile_controller.dart';
import 'package:atlas_app/features/profile/provider/providers.dart';
import 'package:atlas_app/features/profile/widgets/profile_options.dart';
import 'package:atlas_app/imports.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

// Assuming AppColors, formatNumber, accentFont, arabicAccentFont, Routes, openSheet, etc. are defined elsewhere

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key, required this.user, required this.isMe});

  final UserModel user;

  final bool isMe;
  final double avatarRadius = 40.0;
  final double avatarBorder = 4.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(userState).user!; // Ensure 'me' is available
    final size = MediaQuery.sizeOf(context);

    final _user =
        isMe
            ? me
            : ref.watch(selectedUserProvider.select((s) => s?.userId == user.userId ? s : user));

    final double bannerHeight = size.width * 0.30;
    final double avatarVisibleOverlap = avatarRadius + avatarBorder;
    final double topHeaderHeight = bannerHeight + avatarVisibleOverlap + 10;

    double bottomHeaderEstimatedHeight = 160.0;
    if (_user!.bio != null && _user.bio!.isNotEmpty) {
      bottomHeaderEstimatedHeight += 40.0;
    }

    final double totalExpandedHeight = topHeaderHeight + bottomHeaderEstimatedHeight;

    return SliverAppBar(
      expandedHeight: totalExpandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Material(
          color: AppColors.scaffoldBackground,
          child: Column(
            children: [
              buildTopHeader(size, isMe, _user, bannerHeight, topHeaderHeight, ref),
              buildBottomHeader(_user),
            ],
          ),
        ),
      ),
      pinned: false,
      floating: true,
      snap: false,
    );
  }

  Widget buildTopHeader(
    Size size,
    bool isMe,
    UserModel currentUser,
    double bannerHeight,
    double totalTopHeaderHeight,
    WidgetRef ref,
  ) {
    return AppRefresh(
      onRefresh: () async {},
      child: SingleChildScrollView(
        child: Builder(
          // Use Builder to get context for navigation/sheets
          builder: (context) {
            return SizedBox(
              height: totalTopHeaderHeight,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: bannerHeight,
                    child: Opacity(
                      opacity: .75,
                      child: FancyShimmerImage(
                        imageUrl: currentUser.banner,
                        boxFit: BoxFit.cover,
                        errorWidget: Container(color: Colors.grey[300]),
                      ),
                    ),
                  ),
                  Positioned(
                    top: bannerHeight - (avatarRadius + avatarBorder),
                    left: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.scaffoldBackground,
                          width: avatarBorder,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: AppColors.primaryAccent,
                        backgroundImage: CachedNetworkImageProvider(currentUser.avatar),
                        radius: avatarRadius,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isMe) ...[
                          InkWell(
                            onTap: () => context.push(Routes.editProfile),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(
                                  128,
                                ), // Use withAlpha for clarity
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(child: Icon(TablerIcons.edit, size: 20)),
                            ),
                          ),
                        ] else ...[
                          InkWell(
                            onTap:
                                () => ref
                                    .read(profileControllerProvider.notifier)
                                    .handleUserFollow(currentUser.userId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(128),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  currentUser.followed == true
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 20,
                                  color:
                                      currentUser.followed == true
                                          ? Colors.pink
                                          : AppColors.whiteColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => openMoreSheet(context, currentUser),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            decoration: BoxDecoration(
                              color: AppColors.scaffoldForeground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(child: Icon(Icons.more_vert, size: 20)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildBottomHeader(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: accentFont,
                ),
              ),
              const Visibility(visible: false, child: Icon(LucideIcons.badge_check)),
            ],
          ),
          Text(
            "@${user.username}",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.mutedSilver.withAlpha(242),
            ), // .95 alpha
          ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 15),
            Text(user.bio!, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.blackColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  buildCount(count: formatNumber(user.followers_count), title: "متابعين"),
                  buildVerticalDivider(),
                  buildCount(count: formatNumber(user.following_count), title: "يتابع"),
                  buildVerticalDivider(),
                  buildCount(count: formatNumber(user.postsCount), title: "منشور"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildVerticalDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: VerticalDivider(color: AppColors.mutedSilver.withAlpha(38)), // .15 alpha
    );
  }

  Expanded buildCount({required String count, required String title}) {
    return Expanded(
      child: Column(
        children: [
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: accentFont)),
          Text(
            title,
            style: TextStyle(
              fontFamily: arabicAccentFont,
              color: AppColors.mutedSilver.withAlpha(242), // .95 alpha
            ),
          ),
        ],
      ),
    );
  }

  void openMoreSheet(BuildContext context, UserModel userForSheet) {
    openSheet(
      context: context,
      child: Consumer(
        builder: (context, ref, _) {
          final me = ref.read(userState).user!;
          final isMe = me.userId == userForSheet.userId;
          return UserProfileOptions(
            user: userForSheet,
            isMe: isMe,
          ); // Ensure UserProfileOptions is defined
        },
      ),
    );
  }
}
