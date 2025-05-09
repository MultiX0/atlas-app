import 'package:atlas_app/core/common/widgets/error_widget.dart';
import 'package:atlas_app/features/profile/controller/profile_controller.dart';
import 'package:atlas_app/features/profile/provider/providers.dart';
import 'package:atlas_app/features/profile/widgets/profile_body.dart';
import 'package:atlas_app/features/profile/widgets/profile_header_widget.dart';
import 'package:atlas_app/features/profile/widgets/profile_loadig.dart';
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
  late String userId;

  @override
  void initState() {
    final me = ref.read(userState).user!;
    setState(() {
      if (widget.userId.trim().isEmpty) {
        userId = me.userId;
      } else {
        userId = widget.userId;
      }
    });
    bool isUsername = userId.length != 36;

    bool isMe =
        isUsername ? (me.username == userId) : (me.userId == userId) || userId.trim().isEmpty;

    _controller = TabController(length: isMe ? 1 : 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => handleInit());
    super.initState();
  }

  void handleInit() {
    Future.microtask(() {
      final me = ref.read(userState).user!;
      bool isUsername = userId.length != 36;

      bool isMe =
          isUsername ? (me.username == userId) : (me.userId == userId) || userId.trim().isEmpty;
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
    final me = ref.read(userState).user!;
    final userId = this.userId;
    bool isUsername = userId.length != 36;

    bool isMe =
        isUsername ? (me.username == userId) : (me.userId == userId) || userId.trim().isEmpty;
    if (isMe) {
      return Consumer(
        builder: (context, ref, _) {
          final me = ref.watch(userState).user!;
          return buildBody(me, isMe);
        },
      );
    }

    return ref
        .watch(getUserByIdProvider(userId))
        .when(
          data: (user) {
            Future.microtask(() {
              ref.read(selectedUserProvider.notifier).state = user;
            });
            return buildBody(user, isMe);
          },
          error: (error, _) {
            return AtlasErrorPage(
              title: "Not Found",
              message: error.toString(),
              onHome: () => context.pop(),
            );
          },
          loading: () => const CustomScrollView(slivers: [ProfileHeaderShimmer()]),
        );
  }

  Widget buildBody(UserModel user, bool isMe) {
    return SafeArea(
      child: NestedScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        headerSliverBuilder: ((context, innerBoxIsScrolled) {
          return [
            ProfileHeader(user: user, isMe: isMe),
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
