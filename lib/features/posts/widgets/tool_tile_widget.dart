import 'package:atlas_app/imports.dart';

class ToolTileWidget extends ConsumerWidget {
  final String text;
  final IconData icon;
  final Function() onTap;
  final Color overAllColor;

  const ToolTileWidget({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.overAllColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: overAllColor.withValues(alpha: .25),
        foregroundColor: overAllColor,
      ),
      onPressed: onTap,
      label: LanguageText(accent: true, text, style: const TextStyle(fontFamily: arabicAccentFont)),
      icon: Icon(icon, color: overAllColor),
    );
  }
}
