import 'package:atlas_app/features/comics/providers/providers.dart';
import 'package:atlas_app/imports.dart';

class ManhwaTabs extends ConsumerWidget {
  const ManhwaTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(manhwaTabControllerProvider);
    final comic = ref.watch(selectedComicProvider)!;
    final color = comic.color != null ? HexColor(comic.color!) : AppColors.primary;
    if (controller == null) {
      return const Center(child: Row());
    }
    return Visibility(
      maintainState: true,
      maintainSize: false,
      maintainAnimation: true,
      visible: true,
      child: AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 600),
        child: TabBar(
          controller: controller,
          labelStyle: const TextStyle(fontFamily: arabicAccentFont),
          dividerHeight: 0.3,
          labelColor: color,
          dividerColor: AppColors.mutedSilver.withValues(alpha: .45),
          indicatorColor: color,

          tabs: const [Tab(text: 'معلومات'), Tab(text: 'مراجعات'), Tab(text: 'الشخصيات')],
        ),
      ),
    );
  }
}
