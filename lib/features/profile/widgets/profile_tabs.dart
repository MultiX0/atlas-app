import 'package:atlas_app/imports.dart';

class ProfileTabs extends ConsumerWidget {
  const ProfileTabs({super.key, required this.controller, required this.isMe});

  final TabController controller;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

          tabs: [
            const Tab(text: 'المنشورات'),
            if (!isMe) const Tab(text: 'المفضلة'),
            if (!isMe) const Tab(text: 'أعمال أصلية'),
          ],
        ),
      ),
    );
  }
}
