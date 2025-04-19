import 'package:atlas_app/core/common/widgets/manhwa_poster.dart';
import 'package:atlas_app/features/library/widgets/create_new_sheet.dart';
import 'package:atlas_app/imports.dart';

class MyWork extends ConsumerStatefulWidget {
  const MyWork({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyWorkState();
}

class _MyWorkState extends ConsumerState<MyWork> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openSheet(context: context, child: const CreateNewSheet());
        },
        backgroundColor: AppColors.primary.withValues(alpha: .6),
        child: Icon(Icons.add, color: AppColors.whiteColor),
      ),
      body: GridView.count(
        padding: const EdgeInsets.fromLTRB(13, 15, 13, 15),
        childAspectRatio: 1 / 3.5,
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          ManhwaPoster(
            text: "مابعد النهاية",
            onTap: () {},
            type: "رواية",
            image:
                "https://qlweguljtwgnikrdbply.supabase.co/storage/v1/object/public/public-stotage//0a6da363-baaa-4635-b4aa-a9f3d385d819.png",
          ),
          ManhwaPoster(
            text: "أشرقت",
            onTap: () {},
            type: "رواية",
            image:
                "https://qlweguljtwgnikrdbply.supabase.co/storage/v1/object/public/public-stotage//ChatGPT%20Image%20Apr%2018,%202025,%2007_31_09%20PM.png",
          ),
        ],
      ),
    );
  }
}
