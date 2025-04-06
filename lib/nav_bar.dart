import 'package:atlas_app/features/auth/providers/user_state.dart';
import 'package:atlas_app/features/profile/provider/providers.dart';
import 'package:flutter/cupertino.dart';
import 'imports.dart';
// import '../pages/new_version_page.dart';

class MyNavBar extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MyNavBar({super.key, required this.navigationShell});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyNavBarState();
}

class _MyNavBarState extends ConsumerState<MyNavBar> {
  int page = 0;

  void onTap(BuildContext context, int index) {
    setState(() {
      page = index;
    });

    final me = ref.read(userState);
    ref.read(selectedUserIdProvider.notifier).state = me.user?.userId ?? "";

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // return NewVersionPage();

    return Stack(
      children: [
        Scaffold(
          body: widget.navigationShell,

          bottomNavigationBar: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              double navBarHeight;

              if (screenWidth < 600) {
                // Mobile
                navBarHeight = 60;
              } else if (screenWidth < 1024) {
                // Tablet
                navBarHeight = 90;
              } else if (screenWidth < 1440) {
                // Laptop
                navBarHeight = 100;
              } else {
                // Desktop
                navBarHeight = 120;
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      tabLabelTextStyle: TextStyle(fontFamily: arabicAccentFont),
                    ),
                  ),

                  child: CupertinoTabBar(
                    height: navBarHeight,
                    backgroundColor: AppColors.scaffoldBackground,
                    currentIndex: widget.navigationShell.currentIndex,
                    onTap: (int index) => onTap(context, index),
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.mutedSilver,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(TablerIcons.smart_home),
                        label: "الرئيسية",
                      ),
                      BottomNavigationBarItem(icon: Icon(TablerIcons.sparkles), label: "Ask Ai"),
                      BottomNavigationBarItem(icon: Icon(TablerIcons.category_2), label: "استكشاف"),
                      BottomNavigationBarItem(icon: Icon(LucideIcons.library), label: "المكتبة"),
                      BottomNavigationBarItem(icon: Icon(TablerIcons.user), label: "أنا"),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
