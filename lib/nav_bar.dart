import 'package:atlas_app/features/profile/provider/providers.dart';
import 'package:flutter/cupertino.dart';
import 'imports.dart';
// import '../pages/new_version_page.dart';

class MyNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MyNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return NewVersionPage();

    void onTap(BuildContext context, int index) {
      if (index == 4) {
        final me = ref.read(userState);
        ref.read(selectedUserIdProvider.notifier).state = me.user?.userId ?? "";
      }
      navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
    }

    return Stack(
      children: [
        RepaintBoundary(
          child: Scaffold(
            body: navigationShell,

            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    tabLabelTextStyle: TextStyle(fontFamily: arabicAccentFont),
                  ),
                ),

                child: CupertinoTabBar(
                  backgroundColor: AppColors.scaffoldBackground,
                  currentIndex: navigationShell.currentIndex,
                  onTap: (int index) => onTap(context, index),
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.mutedSilver,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(TablerIcons.smart_home), label: "الرئيسية"),
                    BottomNavigationBarItem(icon: Icon(TablerIcons.sparkles), label: "Ask Ai"),
                    BottomNavigationBarItem(icon: Icon(TablerIcons.category_2), label: "استكشاف"),
                    BottomNavigationBarItem(icon: Icon(LucideIcons.library), label: "المكتبة"),
                    BottomNavigationBarItem(icon: Icon(TablerIcons.user), label: "أنا"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
