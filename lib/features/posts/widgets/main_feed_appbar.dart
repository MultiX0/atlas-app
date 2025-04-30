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
          title: const Text('أطلس'),
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
