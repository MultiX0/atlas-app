import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class CustomToast {
  static void get({
    required String text,
    required IconData icon,
    required ToastificationType type,
    required ToastificationStyle style,
  }) {
    toastification.show(
      title: Text(
        text,
        style: TextStyle(color: AppColors.whiteColor, fontFamily: arabicPrimaryFont),
      ),
      style: style,
      autoCloseDuration: const Duration(seconds: 3),
      type: type,
      backgroundColor: AppColors.primaryAccent,
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
    final hasArabic = Bidi.hasAnyRtl(message);
    Toastification().show(
      borderSide: BorderSide(color: AppColors.greenColor, width: .75),
      backgroundColor: AppColors.primaryAccent,
      applyBlurEffect: true,
      // ignore: deprecated_member_use
      closeButtonShowType: CloseButtonShowType.none,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(
        textDirection: hasArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        message,
        style: TextStyle(
          fontFamily: hasArabic ? arabicAccentFont : accentFont,
          color: AppColors.mutedSilver,
        ),
      ),
      icon: Icon(TablerIcons.check, color: AppColors.greenColor),
    );
  }

  static void soon({String? text}) {
    CustomToast.get(
      text: text ?? "قادم قريبا...",
      icon: LucideIcons.badge_info,
      type: ToastificationType.info,
      style: ToastificationStyle.simple,
    );
  }
}
