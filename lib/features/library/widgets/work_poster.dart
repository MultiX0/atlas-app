import 'package:atlas_app/features/library/models/my_work_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

class WorkPoster extends StatelessWidget {
  const WorkPoster({super.key, required this.work});

  final MyWorkModel work;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FancyShimmerImage(
                    imageUrl: work.poster,
                    shimmerBaseColor: AppColors.primaryAccent,
                    shimmerHighlightColor: AppColors.mutedSilver.withValues(alpha: .025),
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
                      work.title,
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: Text(
              "النوع : ${work.type.startsWith('n') ? "رواية" : "ويبتون"}",
              style: const TextStyle(fontFamily: arabicAccentFont),
            ),
          ),
        ],
      ),
    );
  }
}
