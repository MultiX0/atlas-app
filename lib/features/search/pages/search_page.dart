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
  late FocusNode _focusNode;
  int index = 0;

  @override
  void initState() {
    _searchController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
    _focusNode = FocusNode();
    _tabController.addListener(changeTabIndex);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _focusNode.dispose();
    _tabController.removeListener(changeTabIndex);
    super.dispose();
  }

  void changeTabIndex() {
    setState(() {
      index = _tabController.index;
    });
  }

  // Perform search with specified source
  void performSearch({bool useApi = false}) {
    if (_tabController.index == 0) {
      final searchText = _searchController.text.trim();
      if (searchText.isNotEmpty) {
        ref.read(searchQueryProvider.notifier).state = searchText;
        if (useApi) {
          ref.read(searchGlobalProvider.notifier).state = false;
        } else {
          // Reset to local DB search
          ref.read(searchGlobalProvider.notifier).state = true;
        }

        ref.read(manhwaSearchStateProvider.notifier).search(limit: 15, more: useApi);
      }
    }
    _focusNode.unfocus();
  }

  // Normal search button action - always starts with local DB
  void onTap() {
    performSearch(useApi: false);
  }

  // Action for "ألا ترى ما تبحث عنه؟" - specifically uses API
  void onSearchMoreTap() {
    performSearch(useApi: true);
  }

  @override
  Widget build(BuildContext context) {
    final manhwaState = ref.watch(manhwaSearchStateProvider);
    final hasLocalResults = manhwaState.comics.isNotEmpty;
    final isApiSearch = !ref.watch(searchGlobalProvider);

    // Only show "search more" when we have local results and haven't already used API
    final showSearchMoreOption = hasLocalResults && !isApiSearch;

    return Scaffold(
      appBar: AppBar(
        title: const Text("البحث"),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontFamily: arabicAccentFont),
          dividerHeight: 0.3,
          labelColor: AppColors.primary,
          dividerColor: AppColors.mutedSilver.withValues(alpha: .45),
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: "مانهوا"), Tab(text: "روايات"), Tab(text: "مستخدمين")],
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
                  onPressed: onTap,
                  child: const Center(child: Icon(LucideIcons.search)),
                ),
              ],
            ),
          ),

          // Only show "ألا ترى ما تبحث عنه؟" when we have local results and haven't already used API
          if (showSearchMoreOption && index == 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: InkWell(
                onTap: onSearchMoreTap,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: LanguageText(
                    textAlign: TextAlign.start,
                    "ألا ترى ما تبحث عنه؟ (اضغط هنا)",
                    style: TextStyle(
                      fontFamily: accentFont,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],

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
        focusNode: _focusNode,
        controller: _searchController,
        hintText: "عن ماذا تبحث",
        onFieldSubmitted: (_) => onTap(), // Allow searching on Enter/Submit
        onChanged: (val) {},
      ),
    );
  }
}
