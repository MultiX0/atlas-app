import 'dart:developer';

import 'package:atlas_app/features/notifications/controller/notifications_controller.dart';
import 'package:atlas_app/imports.dart';
import 'package:badges/badges.dart' as badges;

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  static Icon icon = Icon(LucideIcons.bell, color: AppColors.whiteColor);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log("notifications tapped");
        context.push(Routes.notification);
      },
      child: Consumer(
        builder: (context, ref, _) {
          final user = ref.read(userState.select((s) => s.user!));

          return ref
              .watch(unreadNotificationsCountStreamProvider(user.userId))
              .when(
                data: (count) {
                  final numberString = count <= 9 ? "$count" : "+9";
                  return badges.Badge(
                    badgeAnimation: const badges.BadgeAnimation.scale(
                      animationDuration: Duration(milliseconds: 500),
                    ),
                    badgeStyle: badges.BadgeStyle(badgeColor: Colors.red.shade800),
                    position: badges.BadgePosition.topStart(),
                    showBadge: count > 0,
                    badgeContent: Text(
                      numberString,
                      style: TextStyle(fontSize: count <= 9 ? 14 : 8, fontWeight: FontWeight.bold),
                    ),
                    child: icon,
                  );
                },
                error: (error, _) => icon,
                loading: () => icon,
              );
        },
      ),
    );
  }
}
