import 'package:atlas_app/imports.dart';

class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.image,
    required this.novelName,
    required this.username,
    required this.content,
  });

  final String novelName;
  final String username;
  final String image;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: AppColors.primaryAccent,
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset('assets/images/$image', fit: BoxFit.cover)),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,

                    colors: [
                      Colors.transparent,
                      AppColors.scaffoldBackground.withValues(alpha: .55),
                    ],
                    stops: const [0, .35],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(35.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.quote,
                        size: 42,
                        color: image != 'style-1.png' ? AppColors.primary : AppColors.mutedSilver,
                      ),
                      const SizedBox(width: 25),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            novelName,
                            style: const TextStyle(fontFamily: arabicAccentFont, fontSize: 30),
                          ),
                          Text(
                            username,
                            style: const TextStyle(
                              fontFamily: accentFont,
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: content.trim().length > 150 ? 15 : 30),
                  Text(
                    '"${content.trim()}"',
                    maxLines: 7,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: arabicAccentFont,
                      fontSize: content.trim().length > 150 ? 18 : 22,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Image.asset('assets/images/atlas_text_overlay.png', fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }
}
