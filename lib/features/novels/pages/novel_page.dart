import 'dart:developer';

import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/models/novel_model.dart';
import 'package:atlas_app/features/novels/pages/characters_page.dart';
import 'package:atlas_app/features/novels/pages/novel_reviews_page.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/features/novels/widgets/novel_chapters.dart';
import 'package:atlas_app/features/novels/widgets/novel_header.dart';
import 'package:atlas_app/features/novels/widgets/novel_info.dart';
import 'package:atlas_app/features/novels/widgets/novel_tabs.dart';
import 'package:atlas_app/imports.dart';

class NovelPage extends ConsumerStatefulWidget {
  const NovelPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NovelPageState();
}

class _NovelPageState extends ConsumerState<NovelPage> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    setState(() {
      _controller = TabController(length: 4, vsync: this);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleView();
    });
    super.initState();
  }

  void handleView() async {
    await Future.microtask(() {
      ref.read(novelsControllerProvider.notifier).handleNovelView();
      ref.read(novelsControllerProvider.notifier).handleNovelInteraction();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final novel = ref.watch(selectedNovelProvider.select((s) => s!));
    return Scaffold(body: buildBody(novel));
  }

  Widget buildBody(NovelModel novel) {
    log(novel.id);
    return SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: ((context, innerBoxIsScrolled) {
          return [
            const NovelHeader(),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(NovelTabs(controller: _controller)),
                pinned: true,
              ),
            ),
          ];
        }),
        body: TabBarView(
          controller: _controller,
          children: [
            const NovelInfo(),
            NovelChapters(novelId: novel.id),
            NovelReviewsPage(novel: novel),
            const CharactersPage(),
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
