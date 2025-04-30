import 'package:atlas_app/core/common/widgets/manhwa_poster.dart';
import 'package:atlas_app/features/novels/widgets/empty_chapters.dart';
import 'package:atlas_app/features/search/providers/manhwa_search_state.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/foundation.dart';

class ManhwaSearchPage extends ConsumerWidget {
  const ManhwaSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manhwaSearchStateProvider);

    final comics = state.comics;
    if (state.isLoading) {
      return const Loader();
    }

    if (state.error != null) {
      if (kDebugMode) {
        return Center(child: ErrorWidget(Exception(state.error)));
      }
      return const EmptyChapters(text: "حدث خطأ الرجاء المحاولة لاحقا");
    }

    if (comics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/no_data_cry_.gif', height: 130),
            const SizedBox(height: 15),
            const Text(
              "سجل البحث فارغ",
              style: TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return GridView.count(
      padding: const EdgeInsets.fromLTRB(13, 0, 13, 15),
      childAspectRatio: 1 / 1.5,
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children:
          comics.map((comic) {
            return ManhwaPoster(
              text: comic.englishTitle,
              onTap: () => ref.read(navsProvider).goToComicsPage(comic),
              image: comic.image,
            );
          }).toList(),
    );
  }
}
