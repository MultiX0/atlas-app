import 'package:atlas_app/imports.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 3, vsync: this);
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
        title: const Text("Explore"),
        actions: [
          IconButton(
            onPressed: () => context.push(Routes.search),
            icon: const Icon(LucideIcons.search),
            tooltip: "Search",
          ),
        ],
        bottom: TabBar(
          controller: _controller,
          dividerHeight: 0.3,
          labelColor: AppColors.primary,
          dividerColor: AppColors.mutedSilver.withValues(alpha: .45),
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: "Clips"), Tab(text: "Manhwa"), Tab(text: "Novels")],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: const [SizedBox(), SizedBox(), SizedBox()],
      ),
    );
  }
}
