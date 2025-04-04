import 'package:atlas_app/features/search/providers/manhwa_search_state.dart';
import 'package:atlas_app/imports.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

class ManhwaSearchPage extends ConsumerWidget {
  const ManhwaSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manhwaSearchStateProvider);

    final comics = state.comics;
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: ErrorWidget(Exception(state.error)));
    }

    if (comics.isEmpty) {
      return const Center(child: Text("No Data"));
    }

    return GridView.count(
      padding: const EdgeInsets.fromLTRB(13, 0, 13, 15),
      childAspectRatio: 1 / 1.5,
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children:
          comics.map((comic) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FancyShimmerImage(
                    imageUrl: comic.image,
                    shimmerBaseColor: AppColors.primaryAccent,
                    shimmerHighlightColor: AppColors.mutedSilver.withValues(alpha: .05),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [Colors.transparent, AppColors.primaryAccent.withValues(alpha: .9)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.1, 0.9],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      comic.englishTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: accentFont,
                        fontSize: 13,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }
}
