import 'package:atlas_app/imports.dart';

// String _getImage(String name) => 'assets/images/$name.jpg';

class OnboardingFirstPage extends ConsumerStatefulWidget {
  const OnboardingFirstPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnboardingFirstPageState();
}

class _OnboardingFirstPageState extends ConsumerState<OnboardingFirstPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetAvifImage('assets/images/peakpx.avif'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, AppColors.scaffoldBackground],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.1, 0.65],
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(25, 0, 25, size.width * 0.08),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: AvifImage.asset('assets/images/logo_transparent.avif', height: 100),
                      ),
                      const Spacer(),
                      const Text.rich(
                        TextSpan(
                          text: "أهلا بكم في ",
                          children: [
                            TextSpan(text: "أطلس", style: TextStyle(color: AppColors.primary)),
                          ],
                        ),
                        style: TextStyle(fontFamily: arabicAccentFont, fontSize: 42),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "منصتك لاكتشاف المانجا والروايات الأصلية، ومشاركة أعمالك مع مجتمع يعشق الإبداع. سواء كنت قارئًا شغوفًا أو كاتبًا طموحًا، أطلس هو المكان الذي تبدأ فيه رحلتك الأدبية والفنية",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: arabicPrimaryFont,
                          color: AppColors.mutedSilver,
                        ),
                      ),
                      SizedBox(height: size.width * 0.08),
                      CustomButton(
                        text: "استكشف الأن",
                        fontSize: 16,
                        onPressed: () {
                          context.pushReplacement(Routes.loginPage);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
