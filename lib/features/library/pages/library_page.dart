import 'package:atlas_app/features/library/widgets/my_work.dart';
import 'package:atlas_app/imports.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ألمكتبة"),
        centerTitle: true,
        bottom: TabBar(
          controller: _controller,
          labelStyle: const TextStyle(fontFamily: arabicAccentFont),
          dividerHeight: 0.3,
          labelColor: AppColors.primary,
          dividerColor: AppColors.mutedSilver.withValues(alpha: .45),
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: "أعمالي"), Tab(text: "المفضلة")],
        ),
      ),
      body: TabBarView(controller: _controller, children: const [MyWork(), SizedBox()]),
    );
  }
}
