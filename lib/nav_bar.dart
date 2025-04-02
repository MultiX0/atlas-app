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
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: widget.navigationShell,
          ),

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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      tabLabelTextStyle: TextStyle(fontFamily: accentFont),
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
                      BottomNavigationBarItem(icon: Icon(TablerIcons.smart_home), label: "Home"),
                      BottomNavigationBarItem(icon: Icon(TablerIcons.sparkles), label: "Ask Ai"),
                      BottomNavigationBarItem(
                        icon: Icon(TablerIcons.layout_grid),
                        label: "Explore",
                      ),
                      BottomNavigationBarItem(icon: Icon(TablerIcons.device_tv), label: "Clips"),
                      BottomNavigationBarItem(icon: Icon(TablerIcons.user), label: "Profile"),
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
