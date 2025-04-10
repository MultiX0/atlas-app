import 'package:atlas_app/imports.dart';

class AppRefresh extends ConsumerWidget {
  const AppRefresh({super.key, required this.child, required this.onRefresh, this.color});

  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      backgroundColor: AppColors.secondBlackColor,
      color: color ?? AppColors.primary,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
