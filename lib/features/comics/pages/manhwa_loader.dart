import 'dart:developer';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/features/comics/db/comics_db.dart';
import 'package:atlas_app/features/comics/pages/manhwa_page.dart';
import 'package:atlas_app/features/novels/widgets/novel_shimmer_loading.dart';
import 'package:atlas_app/imports.dart';

class ManhwaLoader extends ConsumerStatefulWidget {
  const ManhwaLoader({super.key, required this.comicId});
  final String comicId;

  @override
  ConsumerState<ManhwaLoader> createState() => _NovelLoaderState();
}

class _NovelLoaderState extends ConsumerState<ManhwaLoader> {
  ComicModel? comic;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleNovel();
    });
  }

  Future<void> handleNovel() async {
    try {
      // final stateNovel = ref.read(comicViewsStateProvider.notifier).get(widget.comicId);
      // if (stateNovel != null) {
      //   ref.read(selectedComicProvider.notifier).state = stateNovel;
      //   setState(() {
      //     comic = stateNovel;
      //   });
      //   return;
      // }

      final fetchedComic = await ref.read(comicsDBProvider).fetchComicDetailsFromLocalDb([
        widget.comicId,
      ]);
      if (fetchedComic.isEmpty) {
        if (mounted) {
          CustomToast.error("لا توجد مانهوا بهذا الـ id");
          context.pop();
        }
        return;
      }

      ref.read(selectedComicProvider.notifier).state = fetchedComic.first;
      // ref.read(comicViewsStateProvider.notifier).add(fetchedComic.first);
      if (mounted) {
        setState(() {
          comic = fetchedComic.first;
        });
      }
    } catch (e) {
      if (mounted) {
        CustomToast.error(errorMsg);
        context.pop();
      }
      log(e.toString());
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (comic == null) {
      return const SafeArea(child: NovelDetailShimmer());
    } else {
      return const ManhwaPage(fromSearch: false);
    }
  }
}
