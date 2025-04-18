import 'package:atlas_app/imports.dart';

void openSheet({
  required BuildContext context,
  required Widget child,
  bool scrollControlled = false,
}) {
  showModalBottomSheet(
    backgroundColor: AppColors.blackColor,
    context: context,
    isScrollControlled: scrollControlled,
    builder: (context) => child,
    useRootNavigator: true,
    showDragHandle: true,
    useSafeArea: true,
  );
}
