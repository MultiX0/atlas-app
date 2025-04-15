import 'package:atlas_app/imports.dart';

class HashtagsHeader extends StatelessWidget {
  const HashtagsHeader({super.key, required this.hashtag, this.postCount = 0});

  final String hashtag;
  final int postCount;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final expandedHeight = size.width * 0.75;

    return SliverAppBar(
      backgroundColor: AppColors.primaryAccent,
      floating: true,
      expandedHeight: expandedHeight,
      flexibleSpace: RepaintBoundary(
        child: FlexibleSpaceBar(
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black54, AppColors.blackColor, AppColors.primaryAccent],
                stops: const [0.3, 0.5, 0.9],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Material(
                        color: AppColors.scaffoldForeground,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(LucideIcons.hash, size: 40),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      hashtag,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$postCount منشور',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontFamily: arabicAccentFont,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: .85),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'نشر',
                    style: TextStyle(
                      fontFamily: arabicAccentFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
