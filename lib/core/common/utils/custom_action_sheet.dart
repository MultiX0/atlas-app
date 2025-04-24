import 'package:atlas_app/imports.dart';

class CustomActionSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const CustomActionSheet({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: arabicAccentFont,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
              color: AppColors.scaffoldBackground,
            ),
            child: Material(color: Colors.transparent, child: Column(children: children)),
          ),
        ],
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData icon;

  const ActionTile({super.key, required this.text, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.mutedSilver),
        title: Text(text),
        titleTextStyle: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
      ),
    );
  }
}
