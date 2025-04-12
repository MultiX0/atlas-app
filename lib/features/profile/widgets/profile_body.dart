import 'package:atlas_app/features/profile/pages/posts_page.dart';
import 'package:atlas_app/features/profile/provider/providers.dart';
import 'package:atlas_app/imports.dart';

class ProfileBody extends ConsumerStatefulWidget {
  const ProfileBody({super.key, required this.user});

  final UserModel user;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<ProfileBody> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
    super.initState();
  }

  void init() {
    ref.read(userTabsControllerProvider.notifier).state = _tabController;
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: [ProfilePostsPage(user: widget.user), const SizedBox(), const SizedBox()],
    );
  }
}
