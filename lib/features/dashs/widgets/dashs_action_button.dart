import 'package:atlas_app/imports.dart';

class DashsActionButton extends StatelessWidget {
  const DashsActionButton({super.key, required this.provider});
  final AutoDisposeStateProvider<bool> provider;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final show = ref.watch(provider);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          width: show ? 0 : 56, // Standard FAB size
          height: show ? 0 : 56,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: show ? 0.0 : 1.0,
            child: RepaintBoundary(
              key: const Key('dashs-floating-btn'),
              child: FloatingActionButton(
                heroTag: 'dashs-fab',
                onPressed: show ? null : () => context.push(Routes.newDash),
                backgroundColor: AppColors.primary.withValues(alpha: .6),
                child: Icon(Icons.add, color: AppColors.whiteColor),
              ),
            ),
          ),
        );
      },
    );
  }
}
