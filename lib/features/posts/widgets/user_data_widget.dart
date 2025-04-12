import 'package:atlas_app/imports.dart';

// Widget for user data display
class UserDataWidget extends ConsumerWidget {
  final UserModel me;

  const UserDataWidget({super.key, required this.me});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(me.fullName),
              Text(
                "@${me.username}",
                style: const TextStyle(color: AppColors.mutedSilver, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 15),
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primaryAccent,
            backgroundImage: CachedNetworkAvifImageProvider(me.avatar),
          ),
        ],
      ),
    );
  }
}
