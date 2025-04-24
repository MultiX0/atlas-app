import 'dart:developer';

import 'package:atlas_app/core/common/utils/debouncer/debouncer.dart';
import 'package:atlas_app/core/common/widgets/reports/report_widget.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/imports.dart';
import 'package:share_plus/share_plus.dart';

class NovelHeader extends ConsumerStatefulWidget {
  const NovelHeader({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NovelHeaderState();
}

class _NovelHeaderState extends ConsumerState<NovelHeader> {
  final Debouncer _debouncer = Debouncer();
  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final novel = ref.watch(selectedNovelProvider)!;
    final shadowColor = novel.color.withValues(alpha: .25);

    return SliverToBoxAdapter(
      child: RepaintBoundary(
        child: SizedBox(
          height: size.width * 0.65,

          child: Stack(
            children: [
              if (novel.banner != null) ...[
                CachedNetworkImage(
                  imageUrl: novel.banner!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  key: ValueKey(novel.id),
                  height: size.width * 0.55,
                ),
              ],
              Container(
                height: size.width * 0.6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      novel.banner != null
                          ? AppColors.scaffoldBackground.withValues(alpha: .5)
                          : AppColors.primaryAccent,
                      AppColors.scaffoldBackground,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.1, novel.banner != null ? 0.8 : 0.6],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 15,
                right: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: AppColors.scaffoldBackground,
                            border: Border.all(color: AppColors.scaffoldBackground, width: 2),
                            boxShadow: [
                              BoxShadow(blurRadius: 25, spreadRadius: 0.1, color: shadowColor),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: novel.poster,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 180,
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 15,
                                  spreadRadius: 0.1,
                                  color: AppColors.scaffoldBackground.withValues(alpha: .2),
                                  offset: const Offset(-25, -15),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Text(
                                    textDirection: TextDirection.rtl,
                                    novel.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: arabicAccentFont,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                Text.rich(
                                  textDirection: TextDirection.rtl,
                                  TextSpan(
                                    text: novel.publishedAt == null ? '' : "تم تنشرها في: ",
                                    style: const TextStyle(fontFamily: arabicAccentFont),
                                    children: [
                                      TextSpan(
                                        text:
                                            novel.publishedAt == null
                                                ? "لم يتم النشر بشكل رسمي"
                                                : appDateFormat(novel.publishedAt!),
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(fontFamily: enPrimaryFont),
                                ),
                                Text(
                                  textDirection: TextDirection.rtl,
                                  "التصنيف العمري: ${novel.ageRating}+",
                                  style: const TextStyle(
                                    fontFamily: arabicAccentFont,
                                    color: AppColors.mutedSilver,
                                  ),
                                ),
                                Text(
                                  "الكاتب: @${novel.user.username}",

                                  style: const TextStyle(
                                    fontFamily: arabicAccentFont,
                                    color: AppColors.mutedSilver,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.scaffoldBackground,
                      child: IconButton(
                        color: AppColors.whiteColor,
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        tooltip: "Back",
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      backgroundColor: AppColors.scaffoldBackground,
                      child: IconButton(
                        color: novel.isFavorite ? AppColors.primary : AppColors.whiteColor,
                        onPressed: () {
                          log(novel.isFavorite.toString());
                          _debouncer.debounce(
                            duration: const Duration(milliseconds: 300),
                            onDebounce: () {
                              ref.read(novelsControllerProvider.notifier).handleFavorite(novel);
                            },
                          );
                        },
                        icon: Icon(
                          novel.isFavorite ? TablerIcons.heart_minus : TablerIcons.heart_plus,
                        ),
                        tooltip: "المفضلة",
                      ),
                    ),
                    const SizedBox(width: 15),
                    CircleAvatar(
                      backgroundColor: AppColors.scaffoldBackground,
                      child: IconButton(
                        color: AppColors.whiteColor,
                        onPressed: () async {
                          final _url = 'app.atlasapp.app${Routes.novelPage}/${novel.id}';
                          final text =
                              'اكتشفت رواية رائعة على تطبيق أطلس! جرّب تقرأها من هنا 👉 $_url';
                          await Share.share(text);
                        },
                        icon: const Icon(TablerIcons.share_2),
                        tooltip: "مشاركة",
                      ),
                    ),
                    const SizedBox(width: 15),
                    CircleAvatar(
                      backgroundColor: AppColors.scaffoldBackground,
                      child: IconButton(
                        color: AppColors.whiteColor,
                        onPressed: () => openReportSheet(context, ref),
                        icon: const Icon(TablerIcons.report),
                        tooltip: "ابلاغ",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void openReportSheet(BuildContext context, WidgetRef ref) {
  openSheet(
    context: context,
    child: ReportSheet(
      title: "الإبلاغ عن رواية",
      reasons: const [
        ReportReason(
          title: "محتوى مسيء أو غير لائق",
          subtitle: "تحتوي الرواية على خطاب كراهية، مشاهد جنسية صريحة، أو محتوى غير مناسب.",
        ),
        ReportReason(
          title: "عنف مفرط أو محتوى ضار",
          subtitle: "تشمل الرواية عنفًا غير مبرر، تعذيبًا، أو ترويجًا لإيذاء النفس.",
        ),
        ReportReason(
          title: "انتهاك حقوق الملكية الفكرية",
          subtitle: "تحتوي الرواية على سرقة أدبية أو استخدام محتوى محمي دون تصريح.",
        ),
        ReportReason(
          title: "تحرش أو تنمر",
          subtitle: "تستهدف الرواية أفرادًا أو مجموعات بمضايقات أو تهديدات.",
        ),
        ReportReason(
          title: "محتوى غير قانوني",
          subtitle: "تروج الرواية لأنشطة غير قانونية أو تنتهك القوانين المعمول بها.",
        ),
        ReportReason(
          title: "تصنيف غير صحيح",
          subtitle: "تحتوي الرواية على مواضيع حساسة دون وسمه كـ +18 أو تحت فئة مناسبة.",
        ),
      ],
      onSubmit: (reason) {
        ref
            .read(novelsControllerProvider.notifier)
            .addNovelReport(context: context, report: reason);
      },
    ),
  );
}
