import 'dart:developer';

import 'package:atlas_app/features/notifications/controller/notifications_controller.dart';
import 'package:atlas_app/imports.dart';
import 'package:badges/badges.dart' as badges;

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log("notifications tapped");
      },
      child: badges.Badge(
        badgeContent: Consumer(
          builder: (context, ref, _) {
            final user = ref.read(userState.select((s) => s.user!));
            return ref
                .watch(unreadNotificationsCountStreamProvider(user.userId))
                .when(
                  data: (count) {
                    if (count <= 0) return const SizedBox();
                    final numberString = count <= 9 ? "$count" : "+9";
                    return Text(numberString);
                  },
                  error: (error, _) => const SizedBox(),
                  loading: () => const SizedBox(),
                );
          },
        ),
        child: Icon(LucideIcons.bell, color: AppColors.whiteColor),
      ),
    );
  }
}
