import 'package:atlas_app/features/comics/widgets/reviews_card_container.dart';
import 'package:atlas_app/features/comics/widgets/statistics_column.dart';
import 'package:atlas_app/imports.dart';

class StatisticsCard extends StatelessWidget {
  const StatisticsCard({
    super.key,
    required this.postsCount,
    required this.views,
    required this.favoriteCount,
  });

  final int postsCount;
  final int views;
  final int favoriteCount;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatisticsColumn(title: "منشور", value: postsCount.toString()),
          StatisticsColumn(title: "مشاهدة", value: views.toString()),
          StatisticsColumn(title: "المفضلة", value: favoriteCount.toString()),
        ],
      ),
    );
  }
}
