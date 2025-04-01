import 'package:atlas_app/imports.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final FocusNode? focusNode;
  final int? maxLines;
  final int? minLines;
  final void Function()? onTap;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final String? initialValue;
  final bool readOnly;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.focusNode,
    this.maxLines = 1,
    this.minLines,
    this.onTap,
    this.textInputAction,
    this.onFieldSubmitted,
    this.initialValue,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      focusNode: focusNode,
      maxLines: maxLines,
      minLines: minLines,
      onTap: onTap,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      readOnly: readOnly,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        hintStyle: TextStyle(
          fontFamily: accentFont,
          color: AppColors.mutedSilver.withValues(alpha: .65),
        ),
        filled: true,
        fillColor: AppColors.textFieldFillColor,
        border: InputBorder.none,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Icon(prefixIcon, color: AppColors.mutedSilver.withValues(alpha: .65)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.normalRaduis),
          // borderSide: BorderSide(color: AppColors.primary, width: .5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.normalRaduis),
          borderSide: BorderSide(color: AppColors.primary, width: .5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.normalRaduis),
          // borderSide: BorderSide(color: AppColors.primary, width: .5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.normalRaduis),
          borderSide: BorderSide(color: AppColors.errorColor, width: .5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.normalRaduis),
          borderSide: BorderSide(color: AppColors.errorColor, width: .5),
        ),
      ),
    );
  }
}
