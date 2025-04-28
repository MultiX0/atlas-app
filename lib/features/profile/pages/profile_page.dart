import 'package:atlas_app/features/profile/controller/profile_controller.dart';
import 'package:atlas_app/features/profile/provider/providers.dart';
import 'package:atlas_app/features/profile/widgets/profile_body.dart';
import 'package:atlas_app/features/profile/widgets/profile_header_widget.dart';
import 'package:atlas_app/features/profile/widgets/profile_tabs.dart';
// import 'package:atlas_app/features/profile/widgets/profile_top_info_widget.dart';
import 'package:atlas_app/imports.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _controller;
  @override
  void initState() {
    final me = ref.read(userState).user!;
    bool isMe = (me.userId == widget.userId) || widget.userId.trim().isEmpty;

    _controller = TabController(length: isMe ? 1 : 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => handleInit());
    super.initState();
  }

  void handleInit() {
    Future.microtask(() {
      final me = ref.read(userState).user!;
      bool isMe = (me.userId == widget.userId) || widget.userId.trim().isEmpty;
      if (isMe) {
        ref.read(selectedUserProvider.notifier).state = me;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: buildBodyController());
  }

  Widget buildBodyController() {
    final me = ref.watch(userState).user!;
    final userId = widget.userId;
    bool isMe = (me.userId == widget.userId) || widget.userId.trim().isEmpty;

    if (isMe) {
      return buildBody(me, isMe);
    }

    return ref
        .watch(getUserByIdProvider(userId))
        .when(
          data: (user) {
            return buildBody(user, isMe);
          },
          error: (error, _) => Center(child: ErrorWidget(error)),
          loading: () => const Loader(),
        );
  }

  Widget buildBody(UserModel user, bool isMe) {
    return SafeArea(
      child: NestedScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        headerSliverBuilder: ((context, innerBoxIsScrolled) {
          return [
            ProfileHeader(user: user),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(ProfileTabs(controller: _controller, isMe: isMe)),
              pinned: true,
            ),
          ];
        }),
        body: ProfileBody(isMe: isMe, user: user, controller: _controller),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.scaffoldBackground, child: child);
  }

  @override
  double get maxExtent => 48.0;

  @override
  double get minExtent => 48.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

// class _CondensedHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final UserModel user;
//   final bool visible;
//   final bool isMe;

//   _CondensedHeaderDelegate({required this.user, required this.visible, required this.isMe});

//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return ProfileTopInfo(visible: visible, isMe: isMe, user: user);
//   }

//   @override
//   double get maxExtent => visible ? 50.0 : 0.0;

//   @override
//   double get minExtent => visible ? 50.0 : 0.0;

//   @override
//   bool shouldRebuild(covariant _CondensedHeaderDelegate oldDelegate) {
//     return oldDelegate.visible != visible || oldDelegate.user != user;
//   }
// }
