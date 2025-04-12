import 'package:atlas_app/imports.dart';

class ExternalLinkItem extends StatelessWidget {
  const ExternalLinkItem({super.key, required this.link, required this.index, required this.color});

  final dynamic link; // Using dynamic to match original code type
  final int index;
  final Color color;

  Future<void> _launchUrl(String url) async {
    await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchUrl(link.url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          "$index - ${link.site}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            fontFamily: enPrimaryFont,
            color: color,
          ),
        ),
      ),
    );
  }
}
