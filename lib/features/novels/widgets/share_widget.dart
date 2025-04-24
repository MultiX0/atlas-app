// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';

import 'package:atlas_app/core/services/gal_service.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/features/novels/widgets/share_card.dart';
import 'package:atlas_app/imports.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';
import 'package:uuid/uuid.dart';

class ShareWidget extends ConsumerStatefulWidget {
  const ShareWidget({super.key, required this.content});
  final String content;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends ConsumerState<ShareWidget> {
  List<String> images = [
    'style-2.png',
    'style-3.png',
    'style-4.png',
    'style-5.png',
    'style-6.png',
    'style-7.png',
    'style-1.png',
  ];

  int selected = 0;
  bool isMultipleShare = true;
  final ScreenshotController screenshotController = ScreenshotController();
  @override
  void dispose() {
    super.dispose();
  }

  final List<Map<String, dynamic>> socialMediaShare = [
    {'icon': TablerIcons.brand_instagram},
    {'icon': TablerIcons.brand_facebook, 'platform': SocialPlatform.facebook},
    {'icon': TablerIcons.brand_whatsapp, 'platform': SocialPlatform.whatsapp},
    {'icon': TablerIcons.brand_telegram, 'platform': SocialPlatform.telegram},
    {'icon': TablerIcons.brand_reddit, 'platform': SocialPlatform.reddit},
    {'icon': TablerIcons.brand_x, 'platform': SocialPlatform.twitter},
  ];

  @override
  Widget build(BuildContext context) {
    final novelName = ref.read(selectedNovelProvider.select((s) => s!.title));
    final creatorName = ref.read(selectedNovelProvider.select((s) => s!.user.username));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.all(8),

                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.mutedSilver.withValues(alpha: .25),
                    width: .75,
                  ),
                ),
                child: Screenshot(
                  controller: screenshotController,
                  child: ShareCard(
                    image: images[selected],
                    novelName: novelName,
                    username: creatorName,
                    content: widget.content,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: LanguageText(
                  "أختر الشكل اللذي تفضله",
                  style: TextStyle(color: AppColors.mutedSilver, fontSize: 18),
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, i) {
                    final image = images[i];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selected = i;
                        });
                      },
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: AppColors.primaryAccent,
                        backgroundImage: AssetImage('assets/images/$image'),
                        child:
                            i == selected
                                ? const Icon(LucideIcons.check, color: AppColors.primary)
                                : null,
                      ),
                    );
                  },
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(20.0),
                child: LanguageText(
                  "مشاركة في",
                  style: TextStyle(color: AppColors.mutedSilver, fontSize: 18),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: SizedBox(
                  height: 50,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          socialMediaShare.map((data) {
                            return GestureDetector(
                              onTap: () async {
                                final _mediaPath = await captureWidget();
                                if (_mediaPath == null) return;
                                if (data['platform'] == null) {
                                  await Share.shareXFiles([
                                    XFile(_mediaPath.path),
                                  ], text: "اقتباس رائع من تطبيق أطلس 📚✨");
                                  return;
                                }
                                await SocialSharingPlus.shareToSocialMedia(
                                  data['platform'],
                                  """
                                  "${widget.content}"\n
                                  من رواية $novelName على تطبيق أطلس 📚✨\n
                                  اكتشف المزيد: $appDomain
                                  """,
                                  media: _mediaPath.absolute.path,
                                  isOpenBrowser: true,
                                  onAppNotInstalled: () {},
                                );
                              },
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: AppColors.scaffoldBackground,
                                child: Icon(data['icon'], color: AppColors.primary),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomButton(
                  text: "حفظ في الجهاز",
                  onPressed: () async {
                    final _mediaPath = await captureWidget();
                    if (_mediaPath == null) return;

                    await saveLocalFile(_mediaPath);
                    if (!mounted) return;
                    context.pop();
                  },
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<File?> captureWidget() async {
    Uint8List? imageBytes = await screenshotController.capture();
    // Now you can save or use imageBytes as needed
    if (imageBytes == null) return null;

    // Get the temp directory
    final tempDir = await getTemporaryDirectory();
    const uuid = Uuid();

    // Create a unique file path
    final filePath = '${tempDir.path}/${uuid.v4()}}.png';

    // Write the bytes to the file
    final file = await File(filePath).writeAsBytes(imageBytes);

    return file;
  }
}
