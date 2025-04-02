import 'package:atlas_app/imports.dart';

class AppLogoWidget extends ConsumerWidget {
  const AppLogoWidget({super.key});
  static final cachedLogo = Image.asset('assets/images/logo_atlas.png', height: 150);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(child: cachedLogo);
  }
}
