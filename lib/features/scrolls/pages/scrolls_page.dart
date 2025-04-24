import 'package:atlas_app/imports.dart';

class ScrollsPage extends ConsumerWidget {
  const ScrollsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(64.0),
          child: Image.asset('assets/images/atlas_scroll_soon.png'),
        ),
      ),
    );
  }
}
