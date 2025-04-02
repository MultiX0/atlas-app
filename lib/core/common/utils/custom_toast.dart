import 'package:atlas_app/imports.dart';

class CustomToast {
  static void get({
    required String text,
    required IconData icon,
    required ToastificationType type,
    required ToastificationStyle style,
  }) {
    toastification.show(
      title: Text(text),
      style: style,
      autoCloseDuration: const Duration(seconds: 3),
      type: type,
      icon: Icon(icon),
      alignment: Alignment.topCenter,
      borderSide: const BorderSide(),
    );
  }

  static void error(e) {
    Toastification().show(
      borderSide: BorderSide(color: AppColors.errorColor, width: .75),
      backgroundColor: AppColors.primaryAccent,
      applyBlurEffect: true,
      // ignore: deprecated_member_use
      closeButtonShowType: CloseButtonShowType.none,
      autoCloseDuration: const Duration(seconds: 4),
      title: Text(
        e.toString(),
        style: const TextStyle(fontFamily: accentFont, color: AppColors.mutedSilver),
      ),
      icon: Icon(TablerIcons.error_404, color: AppColors.errorColor),
    );
  }

  static void success(String message) {
    Toastification().show(
      borderSide: BorderSide(color: AppColors.greenColor, width: .75),
      backgroundColor: AppColors.primaryAccent,
      applyBlurEffect: true,
      // ignore: deprecated_member_use
      closeButtonShowType: CloseButtonShowType.none,
      autoCloseDuration: const Duration(seconds: 2),
      title: Text(
        message,
        style: const TextStyle(fontFamily: accentFont, color: AppColors.mutedSilver),
      ),
      icon: Icon(TablerIcons.check, color: AppColors.greenColor),
    );
  }

  static void soon() {
    CustomToast.get(
      text: "Comming Soon",
      icon: LucideIcons.badge_info,

      type: ToastificationType.info,
      style: ToastificationStyle.simple,
    );
  }
}
