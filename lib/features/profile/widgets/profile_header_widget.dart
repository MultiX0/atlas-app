import 'package:atlas_app/features/auth/providers/user_state.dart';
import 'package:atlas_app/imports.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(userState)!.user!;
    bool isMe = me.userId == user.userId;
    final size = MediaQuery.sizeOf(context);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          buildTopHeader(size, isMe),
          Text(user.fullName, style: const TextStyle(fontSize: 18)),
          buildBottomHeader(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildBottomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            "@${user.username}",
            style: TextStyle(fontSize: 13, color: AppColors.mutedSilver.withValues(alpha: .8)),
          ),
          const SizedBox(height: 15),
          const Text("Be yourself; everyone else is already taken."),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                buildCount(count: user.followsCount?.followers ?? "0", title: "Followers"),
                buildCount(count: user.followsCount?.following ?? "0", title: "Following"),
                buildCount(count: "15", title: "Post"),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Share",
                    backgroundColor: AppColors.primaryAccent,
                    textColor: AppColors.whiteColor,
                    horizontalPadding: 10,
                    onPressed: () {},
                    verticalPadding: 10,
                    borderRadius: 15,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    onPressed: () {},
                    borderRadius: 15,
                    text: "Edit Profile",
                    horizontalPadding: 10,
                    verticalPadding: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            left: size.width / 2.65,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mutedSilver.withValues(alpha: .10),
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                ],
                border: Border.all(color: AppColors.scaffoldBackground, width: 4),
                borderRadius: BorderRadius.circular(Spacing.normalRaduis + 10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Spacing.normalRaduis + 10),
                child: FancyShimmerImage(imageUrl: user.avatar, boxFit: BoxFit.cover),
              ),
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
        Text(title),
      ],
    ),
  );
}
