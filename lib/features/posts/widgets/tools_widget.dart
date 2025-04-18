import 'package:atlas_app/features/posts/widgets/post_more_options.dart';
import 'package:atlas_app/features/posts/widgets/tool_tile_widget.dart';
import 'package:atlas_app/imports.dart';

class ToolsWidget extends ConsumerWidget {
  const ToolsWidget({
    super.key,
    required this.selectImages,
    required this.handleOptions,
    required this.canComment,
    required this.canRepost,
  });

  final Function() selectImages;
  final Function(bool canRepost, bool canComment) handleOptions;
  final bool canComment;
  final bool canRepost;

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
              ToolTileWidget(text: "اضافة صور", icon: TablerIcons.photo, onTap: selectImages),
              ToolTileWidget(
                text: "اعدادات اضافية",
                icon: TablerIcons.settings_2,
                onTap:
                    () => postOptionsSheet(
                      context,
                      handleOptions,
                      canComments: canComment,
                      canRepost: canRepost,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
