import 'package:atlas_app/features/profile/provider/providers.dart';
import 'package:atlas_app/imports.dart';

class ProfileTabs extends ConsumerWidget {
  const ProfileTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(userTabsControllerProvider);
    if (controller == null) {
      return const Center(child: Row());
    }
    return Visibility(
      maintainState: true,
      maintainSize: false,
      maintainAnimation: true,
      visible: true,
      child: AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 600),
        child: TabBar(
          controller: controller,
          labelStyle: const TextStyle(fontFamily: arabicAccentFont),
          dividerHeight: 0.3,
          labelColor: AppColors.primary,
          dividerColor: AppColors.mutedSilver.withValues(alpha: .45),
          indicatorColor: AppColors.primary,

          tabs: const [Tab(text: 'المنشورات'), Tab(text: 'المفضلة'), Tab(text: 'أعمال أصلية')],
        ),
      ),
    );
  }
}
