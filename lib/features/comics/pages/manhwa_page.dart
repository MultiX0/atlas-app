import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/features/comics/controller/comics_controller.dart';
import 'package:atlas_app/features/comics/models/comic_model.dart';
import 'package:atlas_app/features/comics/providers/providers.dart';
import 'package:atlas_app/features/comics/widgets/manhwa_data_body.dart';
import 'package:atlas_app/features/comics/widgets/manhwa_data_header.dart';
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
          return [const ManhwaDataHeader()];
        }),
        body: const ManhwaDataBody(),
      ),
    );
  }
}
