import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/features/comics/controller/comics_controller.dart';
import 'package:atlas_app/features/comics/models/comic_model.dart';
import 'package:atlas_app/features/comics/providers/providers.dart';
import 'package:atlas_app/features/comics/widgets/manhwa_data_body.dart';
import 'package:atlas_app/features/comics/widgets/manhwa_data_header.dart';
import 'package:atlas_app/features/comics/widgets/manhwa_top_bar_info.dart';
import 'package:atlas_app/imports.dart';

class ManhwaPage extends ConsumerStatefulWidget {
  const ManhwaPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ManhwaPageState();
}

class _ManhwaPageState extends ConsumerState<ManhwaPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => handleManhwaUpdate());
    super.initState();
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
            SliverPersistentHeader(
              delegate: _CondensedHeaderDelegate(comic: comic, visible: innerBoxIsScrolled),
              pinned: true,
            ),
          ];
        }),
        body: const ManhwaDataBody(),
      ),
    );
  }
}

class _CondensedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ComicModel comic;
  final bool visible;

  _CondensedHeaderDelegate({required this.comic, required this.visible});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ManhwaTopBarInfo(visible: visible);
  }

  @override
  double get maxExtent => visible ? 50.0 : 0.0;

  @override
  double get minExtent => visible ? 50.0 : 0.0;

  @override
  bool shouldRebuild(covariant _CondensedHeaderDelegate oldDelegate) {
    return oldDelegate.visible != visible || oldDelegate.comic != comic;
  }
}
