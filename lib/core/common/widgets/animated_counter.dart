import 'package:atlas_app/imports.dart';

class AnimatedCounter extends ConsumerWidget {
  static const _style = TextStyle(fontSize: 12.0, color: Colors.grey);
  const AnimatedCounter({super.key, required this.count, this.style = _style});

  final int count;
  final TextStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(count.toString(), key: ValueKey<int>(count), style: style),
    );
  }
}
