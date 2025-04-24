import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/imports.dart';

class NovelTabs extends ConsumerWidget {
  const NovelTabs({super.key, required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final novel = ref.watch(selectedNovelProvider)!;
    final color = novel.color;

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

        tabs: const [
          Tab(text: 'معلومات'),
          Tab(text: 'الفصول'),
          Tab(text: 'مراجعات'),
          Tab(text: 'الشخصيات'),
        ],
      ),
    );
  }
}
