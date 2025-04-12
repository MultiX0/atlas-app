import 'package:atlas_app/features/comics/widgets/reviews_card_container.dart';
import 'package:atlas_app/features/comics/widgets/statistics_column.dart';
import 'package:atlas_app/imports.dart';

class StatisticsCard extends StatelessWidget {
  const StatisticsCard({super.key, required this.comic});

  final ComicModel comic;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatisticsColumn(title: "منشور", value: comic.posts_count.toString()),
          StatisticsColumn(title: "مشاهدة", value: comic.views.toString()),
          StatisticsColumn(title: "المفضلة", value: comic.favorite_count.toString()),
        ],
      ),
    );
  }
}
