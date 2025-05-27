import 'package:atlas_app/core/common/widgets/reuseable_comment_widget.dart';
import 'package:atlas_app/features/dashs/models/dash_model.dart';
import 'package:atlas_app/imports.dart';

class DashInteracionsDetails extends StatelessWidget {
  const DashInteracionsDetails({super.key, required this.dash});
  final DashModel dash;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (dash.content != null && dash.content!.isNotEmpty) ...[
          RepaintBoundary(
            child: CommentRichTextView(key: ValueKey(dash.id), text: dash.content!, maxLines: 3),
          ),
        ],

        // TODO Here implement the other interacions like the likes and the comments and the views also shares
      ],
    );
  }
}
