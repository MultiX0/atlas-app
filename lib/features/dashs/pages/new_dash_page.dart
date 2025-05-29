import 'dart:io';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/image_picker.dart';
import 'package:atlas_app/core/common/widgets/markdown_field.dart';
import 'package:atlas_app/features/dashs/controller/dashs_controller.dart';
import 'package:atlas_app/imports.dart';

final _dashContentProvider = StateProvider<String?>((ref) {
  return null;
});

class NewDashPage extends ConsumerStatefulWidget {
  const NewDashPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewDashPageState();
}

class _NewDashPageState extends ConsumerState<NewDashPage> {
  File? image;
  double? imageHeigh;

  void onTap() {
    if (image == null) {
      CustomToast.error('يحب عليك ادخال صورة');
      return;
    }

    ref
        .read(dashsControllerProvider.notifier)
        .postDash(image: image!, context: context, content: ref.read(_dashContentProvider));
  }

  void pickImage() async {
    final _file = await singlePicker();

    if (_file == null) {
      CustomToast.error('يحب عليك ادخال صورة');
      return;
    }
    final decoded = await decodeImageFromList(await _file.readAsBytes());

    setState(() {
      image = File(_file.path);
      imageHeigh = decoded.height.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.65;

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: CustomButton(text: "نشر", onPressed: onTap),
      ),
      appBar: AppBar(centerTitle: true, title: const Text("ومضة جديدة")),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchOutCurve: Curves.linear,
            child:
                image != null
                    ? LayoutBuilder(
                      key: const ValueKey("image"),
                      builder: (context, constraints) {
                        return InkWell(
                          onTap: pickImage,
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            constraints: BoxConstraints(maxHeight: maxHeight),
                            decoration: BoxDecoration(
                              color: AppColors.scaffoldForeground.withValues(alpha: .5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.file(image!, fit: BoxFit.cover),
                          ),
                        );
                      },
                    )
                    : AspectRatio(
                      aspectRatio: 9 / 10,
                      child: Container(
                        key: const ValueKey("placeholder"),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldForeground.withValues(alpha: .5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          onTap: pickImage,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(TablerIcons.edit_circle, size: 45),
                                SizedBox(height: 5),
                                Text(
                                  "انقر لتحميل صورة",
                                  style: TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.scaffoldForeground.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ReusablePostFieldWidget(
              onMarkupChanged: (text) {
                ref.read(_dashContentProvider.notifier).state = text;
              },
              showUserData: false,
              hintText: "اضافة وصف",
              minLines: 3,
              maxLines: 6,
            ),
          ),
        ],
      ),
    );
  }
}
