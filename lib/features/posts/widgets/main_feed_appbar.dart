import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/imports.dart';

class MainFeedAppbar extends StatelessWidget {
  const MainFeedAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      sliver: Directionality(
        textDirection: TextDirection.rtl,
        child: SliverAppBar(
          title: const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('أطلس'),
              SizedBox(width: 2),
              Text(
                "beta",
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: enAccentFont,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          pinned: false,
          floating: true,
          actions: [
            IconButton(
              onPressed: () => CustomToast.soon(),
              icon: Icon(LucideIcons.bell, color: AppColors.whiteColor),
            ),
          ],
          backgroundColor: AppColors.scaffoldBackground,
        ),
      ),
    );
  }
}
