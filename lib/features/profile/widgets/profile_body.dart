import 'package:atlas_app/features/library/pages/user_favorite_page.dart';
import 'package:atlas_app/features/novels/pages/profile_user_novels.dart';
import 'package:atlas_app/features/profile/pages/posts_page.dart';
import 'package:atlas_app/imports.dart';

class ProfileBody extends ConsumerStatefulWidget {
  const ProfileBody({super.key, required this.user, required this.controller, required this.isMe});

  final UserModel user;
  final TabController controller;
  final bool isMe;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<ProfileBody> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.controller,
      children: [
        ProfilePostsPage(user: widget.user),
        if (!widget.isMe) UserFavoritePage(userId: widget.user.userId),
        if (!widget.isMe) ProfileUserNovels(userId: widget.user.userId),
      ],
    );
  }
}
