import 'package:atlas_app/imports.dart';

class ManhwaTabs extends ConsumerWidget {
  const ManhwaTabs({super.key, required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comic = ref.watch(selectedComicProvider)!;
    final color = comic.color != null ? HexColor(comic.color!) : AppColors.primary;

    return Visibility(
      maintainState: true,
      maintainSize: false,
      maintainAnimation: true,
      visible: true,
      child: TabBar(
        controller: controller,
        labelStyle: const TextStyle(fontFamily: arabicAccentFont),
        dividerHeight: 0.3,
        labelColor: color,
        dividerColor: AppColors.mutedSilver.withValues(alpha: .45),
        indicatorColor: color,

        tabs: const [Tab(text: 'معلومات'), Tab(text: 'مراجعات'), Tab(text: 'الشخصيات')],
      ),
    );
  }
}
