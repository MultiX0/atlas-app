import 'dart:developer';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/features/comics/controller/comics_controller.dart';
import 'package:atlas_app/features/comics/widgets/manhwa_characters_widget.dart';
import 'package:atlas_app/features/comics/widgets/manhwa_data_body.dart';
import 'package:atlas_app/features/comics/widgets/manhwa_data_header.dart';
import 'package:atlas_app/features/comics/widgets/manhwa_tabs.dart';
import 'package:atlas_app/features/comics/widgets/reviews_page.dart';
import 'package:atlas_app/imports.dart';

class ManhwaPage extends ConsumerStatefulWidget {
  const ManhwaPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ManhwaPageState();
}

class _ManhwaPageState extends ConsumerState<ManhwaPage> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initTabController();
      handleManhwaUpdate();
      handleView();
    });
    super.initState();
  }

  void handleView() {
    final comic = ref.read(selectedComicProvider)!;
    if (!comic.is_viewed) {
      final me = ref.read(userState).user!;
      ref
          .read(comicsControllerProvider.notifier)
          .viewComic(userId: me.userId, comicId: comic.comicId);
    } else {
      log("i already view this manhwa");
    }
  }

  void initTabController() {
    ref.read(manhwaTabControllerProvider.notifier).state = _controller;
  }

  void handleManhwaUpdate() {
    final comic = ref.watch(selectedComicProvider);
    if (comic == null) {
      CustomToast.error("There's an error please try again later");
      context.pop();
      return;
    }
    ref.read(comicsControllerProvider.notifier).handleComicUpdate(comic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comic = ref.watch(selectedComicProvider)!;
    return Scaffold(body: buildBody(comic));
  }

  Widget buildBody(ComicModel comic) {
    return SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: ((context, innerBoxIsScrolled) {
          return [
            const ManhwaDataHeader(),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(ManhwaTabs(controller: _controller)),
                pinned: true,
              ),
            ),
          ];
        }),
        body: TabBarView(
          controller: _controller,
          children: [
            const ManhwaDataBody(),
            ComicReviewsPage(comic: comic, tabController: _controller, tabIndex: 1),
            ManhwaCharactersWidget(comic: comic),
          ],
        ),
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
