import 'package:atlas_app/imports.dart';

class AppTheme {
  // Colors
  static final blackColor = AppColors.scaffoldBackground; // primary color
  static const greyColor = Color.fromRGBO(26, 39, 45, 1); // secondary color
  static const drawerColor = Color.fromRGBO(18, 18, 18, 1);
  static final whiteColor = AppColors.whiteColor;
  static var redColor = Colors.red.shade500;
  static var blueColor = Colors.blue.shade300;

  // Themes
  static var darkModeAppTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    cardColor: greyColor,
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: AppColors.primary.withValues(alpha: .75),
      selectionHandleColor: AppColors.primary,
    ),
    iconTheme: IconThemeData(color: AppColors.whiteColor),
    appBarTheme: AppBarTheme(
      scrolledUnderElevation: 0,
      elevation: 0,
      titleTextStyle: const TextStyle(fontFamily: accentFont, fontSize: 24),
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: whiteColor),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: drawerColor),
    primaryColor: redColor,
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontFamily: primaryFont, color: whiteColor),
      headlineMedium: TextStyle(fontFamily: primaryFont, color: whiteColor),
      headlineSmall: TextStyle(fontFamily: primaryFont, color: whiteColor),
      bodyLarge: TextStyle(fontFamily: primaryFont, color: whiteColor),
      bodyMedium: TextStyle(fontFamily: primaryFont, color: whiteColor),
      bodySmall: TextStyle(fontFamily: primaryFont, color: whiteColor),
      displayLarge: TextStyle(fontFamily: primaryFont, color: whiteColor),
      displayMedium: TextStyle(fontFamily: primaryFont, color: whiteColor),
      displaySmall: TextStyle(fontFamily: primaryFont, color: whiteColor),
      labelLarge: TextStyle(fontFamily: primaryFont, color: whiteColor),
      labelMedium: TextStyle(fontFamily: primaryFont, color: whiteColor),
      labelSmall: TextStyle(fontFamily: primaryFont, color: whiteColor),
      titleLarge: TextStyle(fontFamily: primaryFont, color: whiteColor),
      titleMedium: TextStyle(fontFamily: primaryFont, color: whiteColor),
      titleSmall: TextStyle(fontFamily: primaryFont, color: whiteColor),
    ),
  );

  static var lightModeAppTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: whiteColor,
    cardColor: greyColor,
    appBarTheme: AppBarTheme(
      backgroundColor: whiteColor,
      elevation: 0,
      iconTheme: IconThemeData(color: blackColor),
    ),
    drawerTheme: DrawerThemeData(backgroundColor: whiteColor),
    primaryColor: redColor,
  );
}

class AppColors {
  static Color scaffoldBackground = HexColor("#0B0B0B");
  static Color scaffoldForeground = HexColor("#202020");
  static Color mutedSilver = HexColor('B8B8B8');
  static Color gold = HexColor('D4AF37');
  static Color primaryAccent = HexColor('1C1C1C');
  static Color errorColor = HexColor('E63946');
  static Color greenColor = Colors.green.shade400;
  // static Color primary = HexColor('#008CFF');
  static const Color primary = Color.fromARGB(255, 78, 175, 255);
  static Color whiteColor = HexColor('#f1f2f4');
  static Color greyColor = HexColor('#848486');
  static Color textSecondary = HexColor("#989898");
  static Color textHint = HexColor("#444444");
  static Color link = HexColor("#4BA7F5");
  static Color textFieldFillColor = HexColor('#1E1F21');
  static Color blackColor = HexColor('#151515');
  static Color secondBlackColor = HexColor("#040606");
}

class AppSizes {
  final EdgeInsets padding;

  AppSizes({required BuildContext context})
    : padding = EdgeInsets.only(
        bottom: MediaQuery.of(context).size.width / 4,
        left: 10,
        right: 10,
        top: 10,
      );

  static double borderRadius = 10.0;

  static const normalPadding = EdgeInsets.symmetric(vertical: 15, horizontal: 25);
}

class Spacing {
  static const normalRaduis = 15.0;
  static const normalGap = 20.0;
}
