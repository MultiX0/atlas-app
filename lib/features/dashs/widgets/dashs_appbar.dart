import 'package:atlas_app/imports.dart';

class DashsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashsAppBar({
    super.key,
    required this.provider,
    this.centerTitle = false,
    required this.keyValue,
    required this.title,
    this.actions,
  });
  final StateProvider<bool> provider;
  final String keyValue;
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final show = ref.watch(provider);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          height: show ? 0 : kToolbarHeight,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: show ? 0.0 : 1.0,
            child: RepaintBoundary(
              child: AppBar(key: Key(keyValue), title: Text(title), actions: actions),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
