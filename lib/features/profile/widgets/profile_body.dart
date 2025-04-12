import 'package:atlas_app/features/profile/pages/posts_page.dart';
import 'package:atlas_app/imports.dart';

class ProfileBody extends ConsumerStatefulWidget {
  const ProfileBody({super.key, required this.user, required this.controller});

  final UserModel user;
  final TabController controller;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<ProfileBody> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.controller,
      children: [ProfilePostsPage(user: widget.user), const SizedBox(), const SizedBox()],
    );
  }
}
