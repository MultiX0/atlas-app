import 'package:atlas_app/imports.dart';

// Widget for generic card
class CardWidget extends ConsumerWidget {
  final double raduis;
  final EdgeInsets padding;
  final Widget child;
  final Color color;

  const CardWidget({
    super.key,
    this.raduis = Spacing.normalRaduis + 5,
    required this.padding,
    required this.child,
    this.color = AppColors.primaryAccent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(raduis),
      ),
      child: child,
    );
  }
}
