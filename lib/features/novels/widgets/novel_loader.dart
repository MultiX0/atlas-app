import 'dart:developer';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/models/novel_model.dart';
import 'package:atlas_app/features/novels/pages/novel_page.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/features/novels/providers/views_state.dart';
import 'package:atlas_app/features/novels/widgets/novel_shimmer_loading.dart';
import 'package:atlas_app/imports.dart';

class NovelLoader extends ConsumerStatefulWidget {
  const NovelLoader({super.key, required this.novelId});
  final String novelId;

  @override
  ConsumerState<NovelLoader> createState() => _NovelLoaderState();
}

class _NovelLoaderState extends ConsumerState<NovelLoader> {
  NovelModel? novel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleNovel();
    });
  }

  Future<void> handleNovel() async {
    try {
      // final stateNovel = ref.read(novelViewsStateProvider.notifier).get(widget.novelId);
      // if (stateNovel != null) {
      //   ref.read(selectedNovelProvider.notifier).state = stateNovel;
      //   setState(() {
      //     novel = stateNovel;
      //   });
      //   return;
      // }

      final fetchedNovel = await ref
          .read(novelsControllerProvider.notifier)
          .getNovel(widget.novelId);
      if (fetchedNovel == null) {
        if (mounted) {
          CustomToast.error("لا توجد رواية بهذا الـ id");
          context.pop();
        }
        return;
      }

      ref.read(selectedNovelProvider.notifier).state = fetchedNovel;
      ref.read(novelViewsStateProvider.notifier).add(fetchedNovel);
      if (mounted) {
        setState(() {
          novel = fetchedNovel;
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
    if (novel == null) {
      return const SafeArea(child: NovelDetailShimmer());
    } else {
      return const NovelPage();
    }
  }
}
