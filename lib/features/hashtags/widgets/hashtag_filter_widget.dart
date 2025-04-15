import 'package:atlas_app/core/common/enum/hashtag_enum.dart';
import 'package:atlas_app/imports.dart';

class HashtagFilterWidget extends StatelessWidget {
  const HashtagFilterWidget({super.key, required this.currentFilter, required this.updateFilter});

  final Function(HashtagFilter) updateFilter;
  final HashtagFilter currentFilter;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        openSheet(
          context: context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [buildTitle(), buildActionList(context)],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              currentFilter == HashtagFilter.LAST_CREATED ? "الأحدث" : "الأكثر تفاعلا",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: arabicAccentFont,
              ),
            ),
            const Spacer(),
            const Icon(LucideIcons.chevron_down),
            const SizedBox(width: 10),
            const Text(
              "ترتيب حسب",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: arabicAccentFont,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionList(BuildContext context) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
      color: AppColors.scaffoldBackground,
    ),
    child: Column(
      children: [
        buildTile(
          "الأحدث",
          TablerIcons.calendar,
          isActive: currentFilter == HashtagFilter.LAST_CREATED,
          onTap: () {
            updateFilter(HashtagFilter.LAST_CREATED);
            context.pop();
          },
        ),
        buildTile(
          "الأكثر تفاعلا",
          isActive: currentFilter == HashtagFilter.MOST_POPULAR,
          TablerIcons.heart,
          onTap: () {
            updateFilter(HashtagFilter.MOST_POPULAR);
            context.pop();
          },
        ),
      ],
    ),
  );

  Widget buildTile(
    String text,
    IconData icon, {
    required Function() onTap,
    bool isActive = false,
  }) => Directionality(
    textDirection: TextDirection.rtl,
    child: ListTile(
      onTap: onTap,
      title: Row(
        children: [
          Text(text),
          if (isActive) ...[
            const Spacer(),
            const Icon(LucideIcons.check, color: AppColors.primary),
          ],
        ],
      ),
      leading: Icon(icon, color: AppColors.mutedSilver),

      titleTextStyle: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
    ),
  );

  Widget buildTitle() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 25),
    child: Text('ترتيب حسب', style: TextStyle(fontFamily: arabicAccentFont, fontSize: 24)),
  );
}
