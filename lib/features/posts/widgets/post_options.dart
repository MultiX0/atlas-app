import 'dart:developer';
import 'package:atlas_app/core/common/enum/post_like_enum.dart';
import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/features/posts/controller/posts_controller.dart';
import 'package:atlas_app/features/posts/widgets/post_report_sheet.dart';
import 'package:atlas_app/router.dart';
import 'package:clipboard/clipboard.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/foundation.dart';

class PostOptions extends StatefulWidget {
  const PostOptions({super.key, required this.isOwner, required this.post, required this.postType});

  final bool isOwner;
  final PostModel post;
  final PostLikeEnum postType;

  @override
  State<PostOptions> createState() => _PostOptionsSheetState();
}

class _PostOptionsSheetState extends State<PostOptions> {
  bool isPinned = false;
  bool isSaved = false;
  @override
  void initState() {
    isPinned = widget.post.isPinned;
    isSaved = widget.post.isSaved;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [buildTitle(), buildActionList(context, isOwner: widget.isOwner)],
    );
  }

  final Debouncer _debouncer = Debouncer();

  Widget buildActionList(BuildContext context, {required bool isOwner}) => Container(
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
          final router = ref.read(routerProvider);
          if (kDebugMode) {
            print(router.state.fullPath);
          }
          bool profile = (router.state.fullPath ?? "").contains(Routes.profile);

          return Column(
            children: [
              buildTile(
                "ابلاغ",
                visible: !isOwner,
                LucideIcons.flag,
                onTap: () {
                  context.pop();
                  openSheet(
                    context: context,
                    child: const PostReportSheet(),
                    scrollControlled: true,
                  );
                  log("repeat clicked");
                },
              ),
              buildTile(
                visible: (isOwner && profile),
                "تعديل",
                TablerIcons.edit_circle,
                onTap: () {
                  context.pop();
                  ref.read(selectedPostProvider.notifier).state = widget.post;
                  context.push("${Routes.makePostPage}/${PostType.edit.name}/edit-post");
                },
              ),
              buildTile(
                isSaved ? "ازالة من المحفوظات" : "حفظ المنشور",
                isSaved ? LucideIcons.bookmark_minus : LucideIcons.bookmark,
                onTap: () {
                  try {
                    setState(() {
                      isSaved = !isSaved;
                    });
                    _debouncer.debounce(
                      duration: const Duration(milliseconds: 200),
                      onDebounce: () {
                        ref
                            .read(postsControllerProvider.notifier)
                            .handlePostSave(widget.post, postType: widget.postType);
                      },
                    );
                  } catch (e) {
                    setState(() {
                      isPinned = !isPinned;
                    });
                    log(e.toString());
                    rethrow;
                  }
                },
              ),
              buildTile(
                visible: (isOwner && profile),

                "حذف",
                LucideIcons.trash_2,
                onTap: () {
                  context.pop();
                  alertDialog();
                },
              ),
              buildTile(
                visible: (isOwner && profile),
                isPinned ? "الغاء التثبيت" : "تثبيت",
                isPinned ? LucideIcons.pin_off : LucideIcons.pin,
                onTap: () {
                  try {
                    setState(() {
                      isPinned = !isPinned;
                    });
                    _debouncer.debounce(
                      duration: const Duration(milliseconds: 200),
                      onDebounce: () {
                        ref.read(postsControllerProvider.notifier).handlePostPin(widget.post);
                      },
                    );
                  } catch (e) {
                    setState(() {
                      isPinned = !isPinned;
                    });
                    log(e.toString());
                  }
                },
              ),
              buildTile(
                "نسخ الرابط",
                LucideIcons.link_2,
                onTap: () {
                  FlutterClipboard.copy("$appDomain/${Routes.postPage}/${widget.post.postId}");
                  CustomToast.success("تم نسخ رابط المنشور بنجاح");
                  context.pop();
                },
              ),
            ],
          );
        },
      ),
    ),
  );

  void alertDialog() {
    const btnStyle = TextStyle(fontFamily: arabicAccentFont, color: AppColors.primary);
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            return AlertDialog(
              backgroundColor: AppColors.primaryAccent,
              title: const Text(
                textDirection: TextDirection.rtl,
                " هل أنت متأكد من حذف هذا المنشور؟",
                style: TextStyle(fontFamily: arabicAccentFont),
              ),
              content: const Text(
                'لا يمكن التراجع عن هذا الإجراء. سيتم حذف المنشور وجميع التفاعلات المرتبطة به نهائيًا.',
                style: TextStyle(fontFamily: arabicPrimaryFont),
                textDirection: TextDirection.rtl,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(postsControllerProvider.notifier).deletePost(widget.post.postId);
                    context.pop();
                  },
                  child: const Text("الااستمرار", style: btnStyle),
                ),
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text("عودة", style: btnStyle),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildTile(String text, IconData icon, {required Function() onTap, bool visible = true}) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListTile(
        onTap: onTap,
        title: Row(children: [Text(text)]),
        leading: Icon(icon, color: AppColors.mutedSilver),

        titleTextStyle: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
      ),
    );
  }

  Widget buildTitle() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 25),
    child: Text('الخيارات', style: TextStyle(fontFamily: arabicAccentFont, fontSize: 24)),
  );
}
