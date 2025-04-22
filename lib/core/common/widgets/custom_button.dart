import 'package:atlas_app/imports.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double verticalPadding;
  final double horizontalPadding;
  final bool isLoading;
  final double borderRadius;
  final FontWeight fontWeight;
  final double? fontSize;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double iconSize;
  final Color? iconColor;
  final bool disabled;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.verticalPadding = 15,
    this.horizontalPadding = 15,
    this.isLoading = false,
    this.borderRadius = 30,
    this.fontWeight = FontWeight.bold,
    this.fontSize,
    this.prefixIcon,
    this.suffixIcon,
    this.iconSize = 18,
    this.iconColor,
    this.disabled = false,
  });
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SizedBox(
      width: width ?? size.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
          foregroundColor: textColor ?? Colors.black,
          backgroundColor:
              disabled
                  ? (backgroundColor ?? AppColors.mutedSilver).withValues(alpha: .5)
                  : backgroundColor ?? AppColors.mutedSilver,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
        onPressed: disabled ? null : (isLoading ? () {} : onPressed),
        child:
            isLoading
                ? LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.scaffoldBackground,
                  size: 20,
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(
                        prefixIcon,
                        size: iconSize,
                        color: iconColor ?? textColor ?? Colors.black,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontFamily: arabicAccentFont,
                        fontWeight: fontWeight,
                        fontSize: fontSize,
                      ),
                    ),
                    if (suffixIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        suffixIcon,
                        size: iconSize,
                        color: iconColor ?? textColor ?? Colors.black,
                      ),
                    ],
                  ],
                ),
      ),
    );
  }
}
