import 'package:atlas_app/imports.dart';

class CardContainer extends StatelessWidget {
  const CardContainer({
    super.key,
    this.raduis = Spacing.normalRaduis + 5,
    required this.padding,
    required this.child,
    this.color = AppColors.primaryAccent,
  });

  final double raduis;
  final EdgeInsets padding;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: padding,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(raduis)),
        child: child,
      ),
    );
  }
}
