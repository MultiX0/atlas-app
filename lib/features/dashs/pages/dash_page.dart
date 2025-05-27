import 'dart:async';

import 'package:atlas_app/core/common/widgets/error_widget.dart';
import 'package:atlas_app/features/dashs/providers/dash_page_state.dart';
import 'package:atlas_app/features/dashs/widgets/dash_user_card.dart';
import 'package:atlas_app/features/dashs/widgets/dashs_appbar.dart';
import 'package:atlas_app/imports.dart';
import 'package:shimmer/shimmer.dart';

final _isScrolling = StateProvider<bool>((ref) {
  return false;
});

class DashPage extends ConsumerStatefulWidget {
  const DashPage({super.key, required this.dashId});

  final String dashId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashPageState();
}

class _DashPageState extends ConsumerState<DashPage> {
  final _scrollController = ScrollController();
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchDash());
  }

  void fetchDash({bool refresh = false}) {
    ref.read(dashPageStateProvider(widget.dashId).notifier).fetchDash(refresh: refresh);
  }

  void _scrollListener() {
    _scrollTimer?.cancel();

    if (!ref.read(_isScrolling)) {
      ref.read(_isScrolling.notifier).state = true;
    }

    _scrollTimer = Timer(const Duration(milliseconds: 600), () {
      ref.read(_isScrolling.notifier).state = false;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * .75;
    return SafeArea(
      child: Scaffold(
        appBar: DashsAppBar(
          provider: _isScrolling,
          keyValue: 'dash-page-appbar',
          title: '',
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.more_vert, color: AppColors.whiteColor)),
          ],
        ),
        body: RepaintBoundary(
          child: Consumer(
            builder: (context, ref, child) {
              final provider = dashPageStateProvider(widget.dashId);
              final isLoading = ref.watch(provider.select((s) => s.isLoading));
              if (isLoading) return child!;
              final error = ref.watch(provider.select((s) => s.error));
              if (error != null) return AtlasErrorPage(message: error.toString());
              final dash = ref.watch(provider.select((s) => s.dash));
              if (dash == null) {
                return const AtlasErrorPage(message: 'current dash has value of null');
              }

              return ListView(
                controller: _scrollController,
                addRepaintBoundaries: true,
                addSemanticIndexes: true,
                cacheExtent: MediaQuery.sizeOf(context).height,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxHeight,
                      minWidth: MediaQuery.sizeOf(context).width,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: dash.image,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[800]!,
                            highlightColor: Colors.grey[400]!,
                            child: Container(color: Colors.grey[600]),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[600],
                            child: const Icon(Icons.broken_image),
                          ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  DashUserCard(user: dash.user!),
                ],
              );
            },
            child: const Loader(),
          ),
        ),
      ),
    );
  }
}
