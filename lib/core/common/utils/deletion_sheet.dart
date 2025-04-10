import 'package:atlas_app/imports.dart';

class DeleteSheet extends StatelessWidget {
  const DeleteSheet({super.key, required this.message, required this.onDelete});

  final String message;
  final Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [buildTitle(), buildDeleteBlock(context)],
    );
  }

  Widget buildTitle() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 25),
    child: Text('حذف', style: TextStyle(fontFamily: arabicAccentFont, fontSize: 24)),
  );

  Widget buildDeleteBlock(BuildContext context) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
      color: AppColors.scaffoldBackground,
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        buildTile(
          'نعم، احذف',
          TablerIcons.trash,
          onTap: () {
            onDelete(); // perform delete
          },
        ),
        buildTile(
          'الغاء',
          TablerIcons.arrow_back,
          onTap: () {
            context.pop(); // close sheet
          },
        ),
      ],
    ),
  );

  Widget buildTile(String text, IconData icon, {required VoidCallback onTap}) => Directionality(
    textDirection: TextDirection.rtl,
    child: ListTile(
      onTap: onTap,
      title: Text(text),
      leading: Icon(icon),
      titleTextStyle: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
    ),
  );
}
