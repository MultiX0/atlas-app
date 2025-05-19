import 'package:atlas_app/features/notifications/db/notifications_db.dart';
import 'package:atlas_app/imports.dart';

final notificationsControllerProvider = StateNotifierProvider<NotificationsController, bool>((ref) {
  return NotificationsController(ref: ref);
});

final unreadNotificationsCountStreamProvider = StreamProvider.family<int, String>((ref, userId) {
  final controller = ref.watch(notificationsControllerProvider.notifier);
  return controller.getUnreadedNotificationsCount(userId);
});

class NotificationsController extends StateNotifier<bool> {
  NotificationsController({required Ref ref}) : super(false);
  NotificationsDb get _db => NotificationsDb();

  Stream<int> getUnreadedNotificationsCount(String userId) {
    return _db.getUnreadedNotificationsCount(userId);
  }
}
