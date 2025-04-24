import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/imports.dart';

class CreateNewSheet extends StatelessWidget {
  const CreateNewSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "نوع العمل",
          style: TextStyle(fontFamily: arabicAccentFont, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        buildActionList(context),
      ],
    );
  }

  Widget buildActionList(BuildContext context) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
      color: AppColors.scaffoldBackground,
    ),
    child: Material(
      color: Colors.transparent,
      child: Consumer(
        builder: (context, ref, _) {
          return Column(
            children: [
              buildTile("كوميك", onTap: () => CustomToast.soon(), icons: LucideIcons.sparkle),
              buildTile(
                "رواية",
                onTap: () {
                  context.pop();
                  context.push(Routes.addNovelPage);
                },
                icons: TablerIcons.book,
              ),
            ],
          );
        },
      ),
    ),
  );

  Widget buildTile(String text, {required Function() onTap, required IconData icons}) {
    return Builder(
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListTile(
            onTap: onTap,
            leading: Icon(icons, color: AppColors.mutedSilver),
            title: Row(children: [Text(text)]),

            titleTextStyle: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
          ),
        );
      },
    );
  }
}
