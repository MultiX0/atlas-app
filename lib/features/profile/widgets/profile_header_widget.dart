import 'package:atlas_app/imports.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(userState).user!;
    bool isMe = me.userId == user.userId;
    final size = MediaQuery.sizeOf(context);

    return SliverAppBar(
      expandedHeight: size.width * .85,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Material(
          color: AppColors.scaffoldBackground,
          child: Column(children: [buildTopHeader(size, isMe), buildBottomHeader()]),
        ),
      ),
      pinned: false,
      floating: true,
      snap: false,
    );
  }

  Widget buildBottomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: accentFont,
            ),
          ),
          Text(
            "@${user.username}",
            style: TextStyle(fontSize: 13, color: AppColors.mutedSilver.withValues(alpha: .95)),
          ),
          if (user.bio != null) ...[
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
                  buildCount(count: user.followsCount?.followers ?? "0", title: "متابعين"),
                  buildVerticalDivider(),
                  buildCount(count: user.followsCount?.following ?? "0", title: "يتابع"),
                  buildVerticalDivider(),
                  buildCount(count: "15", title: "منشور"),
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
      child: VerticalDivider(color: AppColors.mutedSilver.withValues(alpha: .15)),
    );
  }

  SizedBox buildTopHeader(Size size, bool isMe) {
    return SizedBox(
      height: size.width * 0.45,
      child: Stack(
        children: [
          Opacity(
            opacity: .75,
            child: FancyShimmerImage(
              imageUrl: user.banner,
              boxFit: BoxFit.cover,
              height: size.width * 0.30,
              width: double.infinity,
            ),
          ),
          Positioned(
            bottom: 15,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.scaffoldBackground, width: 4),
              ),
              child: CircleAvatar(
                backgroundColor: AppColors.primaryAccent,
                backgroundImage: CachedNetworkImageProvider(user.avatar),
                radius: 40,
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Icon(Icons.favorite_border, size: 20)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldForeground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Icon(Icons.more_vert, size: 20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded buildCount({required String count, required String title}) => Expanded(
    child: Column(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: accentFont)),
        Text(
          title,
          style: TextStyle(
            fontFamily: arabicAccentFont,
            color: AppColors.mutedSilver.withValues(alpha: .95),
          ),
        ),
      ],
    ),
  );
}
