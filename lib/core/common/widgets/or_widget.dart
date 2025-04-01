import 'package:atlas_app/imports.dart';

class OrWidget extends StatelessWidget {
  const OrWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.mutedSilver.withValues(alpha: .65))),
        const SizedBox(width: 15),
        Text(
          "OR",
          style: TextStyle(
            fontFamily: accentFont,
            fontSize: 16,
            color: AppColors.mutedSilver.withValues(alpha: .65),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(child: Divider(color: AppColors.mutedSilver.withValues(alpha: .65))),
      ],
    );
  }
}
