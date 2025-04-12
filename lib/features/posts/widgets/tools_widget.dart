import 'package:atlas_app/features/posts/widgets/tool_tile_widget.dart';
import 'package:atlas_app/imports.dart';

class ToolsWidget extends ConsumerWidget {
  const ToolsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 10,
            children: [
              ToolTileWidget(text: "اضافة صور", icon: TablerIcons.photo, onTap: () {}),
              ToolTileWidget(text: "منشن شخصية", icon: TablerIcons.slash, onTap: () {}),
              ToolTileWidget(text: "منشن مانهوا", icon: TablerIcons.slash, onTap: () {}),
              ToolTileWidget(text: "منشن رواية", icon: TablerIcons.book, onTap: () {}),
              ToolTileWidget(text: "اعدادات اضافية", icon: TablerIcons.settings_2, onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
