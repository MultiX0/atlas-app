import 'package:atlas_app/core/common/widgets/cached_avatar.dart';
import 'package:atlas_app/features/dashs/models/dash_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:timeago/timeago.dart' as timeago;

class DashUserCard extends StatelessWidget {
  const DashUserCard({super.key, required this.dash});
  final DashModel dash;

  @override
  Widget build(BuildContext context) {
    final user = dash.user!;
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
                Row(
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: accentFont,
                      ),
                    ),
                    if (user.isAdmin || user.official) ...[const SizedBox(width: 5)],
                    Visibility(
                      visible: (user.isAdmin || user.official),
                      child: const Icon(
                        LucideIcons.badge_check,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text("·"),
                    const SizedBox(width: 5),
                    Text(
                      timeago.format(dash.createdAt, locale: "ar"),
                      style: const TextStyle(color: AppColors.mutedSilver, fontSize: 12),
                    ),
                  ],
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
