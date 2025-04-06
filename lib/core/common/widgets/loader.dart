import 'package:atlas_app/imports.dart';

class Loader extends ConsumerWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: LoadingAnimationWidget.fourRotatingDots(color: AppColors.whiteColor, size: 35),
    );
  }
}
