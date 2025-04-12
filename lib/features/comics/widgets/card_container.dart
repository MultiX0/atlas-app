import 'package:atlas_app/imports.dart';

class CardContainer extends StatelessWidget {
  const CardContainer({
    super.key,
    this.raduis = Spacing.normalRaduis + 5,
    required this.padding,
    required this.child,
  });

  final double raduis;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.primaryAccent,
        borderRadius: BorderRadius.circular(raduis),
      ),
      child: child,
    );
  }
}
