import 'package:atlas_app/features/profile/provider/providers.dart';
import 'package:atlas_app/imports.dart';

class ProfileBody extends ConsumerStatefulWidget {
  const ProfileBody({super.key});

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
      children: [
        ListView.builder(
          itemCount: 20,
          itemBuilder: (context, i) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              height: 150,
              width: double.infinity,
              color: AppColors.primaryAccent,
            );
          },
        ),
        const SizedBox(),
        const SizedBox(),
      ],
    );
  }
}
