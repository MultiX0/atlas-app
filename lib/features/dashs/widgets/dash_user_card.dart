import 'package:atlas_app/core/common/widgets/cached_avatar.dart';
import 'package:atlas_app/imports.dart';

class DashUserCard extends StatelessWidget {
  const DashUserCard({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('${Routes.user}/${user.userId}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          children: [
            CachedAvatar(avatar: user.avatar),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: accentFont,
                  ),
                ),
                Text(
                  "@${user.username}",
                  style: TextStyle(fontSize: 13, color: AppColors.mutedSilver.withAlpha(242)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
