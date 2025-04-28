import 'package:atlas_app/imports.dart';

class AppLogoWidget extends ConsumerWidget {
  const AppLogoWidget({super.key});
  static final cachedLogo = Image.asset('assets/images/logo_at.png', height: 200);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(child: cachedLogo);
  }
}
