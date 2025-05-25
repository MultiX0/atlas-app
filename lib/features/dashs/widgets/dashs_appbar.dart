import 'package:atlas_app/imports.dart';

class DashsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashsAppBar({super.key, required this.provider});
  final StateProvider<bool> provider;

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
              child: AppBar(key: const Key('dashs-appbar'), title: const Text('ومضات')),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
