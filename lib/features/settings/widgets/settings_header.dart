import 'package:atlas_app/imports.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key, this.title, this.description, this.subtitle});

  final String? title;
  final String? subtitle;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              fontFamily: arabicAccentFont,
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (subtitle != null) ...[
          Text(
            subtitle!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,

              fontSize: 18,
              fontFamily: arabicAccentFont,
            ),
          ),
        ],
        if (description != null) ...[
          Text(
            description!,
            style: const TextStyle(
              // Secure your account by managing your password settings.
              fontSize: 15,
              color: Colors.white70,
              fontFamily: arabicAccentFont,
            ),
          ),
        ],
        const SizedBox(height: 15),
      ],
    );
  }
}
