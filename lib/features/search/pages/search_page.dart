import 'package:atlas_app/features/search/pages/manhwa_search_page.dart';
import 'package:atlas_app/features/search/providers/manhwa_search_state.dart';
import 'package:atlas_app/features/search/providers/providers.dart';
import 'package:atlas_app/imports.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late TabController _tabController;

  @override
  void initState() {
    _searchController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        bottom: TabBar(
          controller: _tabController,
          dividerHeight: 0.3,
          labelColor: AppColors.primary,
          dividerColor: AppColors.mutedSilver.withValues(alpha: .45),
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: "Manhwa"), Tab(text: "Novels"), Tab(text: "People")],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Row(
              children: [
                buildSearchField(),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: AppColors.whiteColor,
                    padding: const EdgeInsets.all(18),
                  ),
                  onPressed: () {
                    if (_tabController.index == 0) {
                      ref.read(searchQueryProvider.notifier).state = _searchController.text.trim();
                      ref.read(manhwaSearchStateProvider.notifier).search();
                    }
                  },
                  child: const Center(child: Icon(LucideIcons.search)),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [ManhwaSearchPage(), SizedBox(), SizedBox()],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchField() {
    return Expanded(
      child: CustomTextFormField(
        raduis: 12,
        controller: _searchController,
        hintText: "Searching...",
        onChanged: (val) {},
      ),
    );
  }
}
