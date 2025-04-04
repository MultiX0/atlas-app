import 'package:atlas_app/imports.dart';

class ProfileTopInfo extends ConsumerWidget {
  const ProfileTopInfo({super.key, required this.visible, required this.isMe, required this.user});

  final bool visible;
  final bool isMe;
  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      maintainState: true,
      maintainSize: false,
      maintainAnimation: true,
      visible: visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 600),
        child: Container(
          color: AppColors.scaffoldBackground,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: isMe ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: CachedNetworkAvifImageProvider(user.avatar),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    user.username,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  if (isMe) ...[const Spacer(), buildOwnerMethods()],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row buildOwnerMethods() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          tooltip: "Edit Profile",
          onPressed: () {},
          icon: const Icon(TablerIcons.edit, color: AppColors.mutedSilver),
        ),
        IconButton(
          tooltip: "New Post",
          onPressed: () {},
          icon: const Icon(TablerIcons.user_edit, color: AppColors.mutedSilver),
        ),
      ],
    );
  }
}
