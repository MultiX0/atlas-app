import 'dart:developer';

import 'package:atlas_app/imports.dart';

void postOptionsSheet(
  BuildContext context,
  final Function(bool canRepost, bool canComment) handleOptions, {
  required bool canComments,
  required bool canRepost,
}) {
  openSheet(
    context: context,
    child: PostOptionsSheet(
      handleOptions: handleOptions,
      canComment: canComments,
      canRepost: canRepost,
    ),
  );
}

class PostOptionsSheet extends StatefulWidget {
  const PostOptionsSheet({
    super.key,
    required this.handleOptions,
    required this.canComment,
    required this.canRepost,
  });

  final Function(bool canRepost, bool canComment) handleOptions;
  final bool canComment;
  final bool canRepost;

  @override
  State<PostOptionsSheet> createState() => _PostOptionsSheetState();
}

class _PostOptionsSheetState extends State<PostOptionsSheet> {
  bool? canRepost;
  bool? canComment;
  @override
  void initState() {
    canRepost = widget.canRepost;
    canComment = widget.canComment;
    super.initState();
  }

  void handleChange(bool canRepost, bool canComment) {
    setState(() {
      this.canRepost = canRepost;
      this.canComment = canComment;
    });

    widget.handleOptions(canRepost, canComment);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTitle(),
        buildActionList(
          context,
          handleChange,
          canComments: canComment ?? true,
          canRepost: canRepost ?? true,
        ),
      ],
    );
  }
}

Widget buildActionList(
  BuildContext context,
  final Function(bool canRepost, bool canComment) handleOptions, {
  required bool canComments,
  required bool canRepost,
}) => Container(
  margin: const EdgeInsets.all(16),
  padding: const EdgeInsets.all(8),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
    color: AppColors.scaffoldBackground,
  ),
  child: Column(
    children: [
      buildTile(
        "تفعيل التعليقات",
        TablerIcons.message_circle,
        isActive: canComments,
        onTap: () {
          log("comments clicked");
          handleOptions(canRepost, !canComments);
        },
      ),
      buildTile(
        "اعادة النشر",
        isActive: canRepost,
        LucideIcons.repeat,
        onTap: () {
          log("repeat clicked");
          handleOptions(!canRepost, canComments);
        },
      ),
    ],
  ),
);

Widget buildTile(String text, IconData icon, {required Function() onTap, bool isActive = false}) =>
    Directionality(
      textDirection: TextDirection.rtl,
      child: ListTile(
        onTap: onTap,
        title: Row(
          children: [
            Text(text),
            const Spacer(),
            Switch(
              value: isActive,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
              inactiveTrackColor: AppColors.mutedSilver,
              inactiveThumbColor: AppColors.primaryAccent,
            ),
          ],
        ),
        leading: Icon(icon, color: AppColors.mutedSilver),

        titleTextStyle: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
      ),
    );

Widget buildTitle() => const Padding(
  padding: EdgeInsets.symmetric(horizontal: 25),
  child: Text('اعدادات اضافية', style: TextStyle(fontFamily: arabicAccentFont, fontSize: 24)),
);
