import 'dart:async';
import 'package:atlas_app/imports.dart';

class PinCodeConfirmPage extends ConsumerStatefulWidget {
  const PinCodeConfirmPage({super.key, required this.next, required this.prevs});
  final VoidCallback next;
  final VoidCallback prevs;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PinCodeConfirmPageState();
}

class _PinCodeConfirmPageState extends ConsumerState<PinCodeConfirmPage> {
  String? notCorrect;
  int _resendCooldown = 0;
  Timer? _timer;
  bool correctCode = false;
  static const String _cooldownKey = 'resend_cooldown_timestamp';
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
    _loadCooldownState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCooldownState() async {
    final prefs = await SharedPreferences.getInstance();
    final cooldownEndTime = prefs.getInt(_cooldownKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cooldownEndTime > now) {
      final remainingTime = (cooldownEndTime - now) ~/ 1000;
      setState(() {
        _resendCooldown = remainingTime;
      });
      _startTimer();
    } else {
      _resendCode();
    }
  }

  Future<void> _saveCooldownState() async {
    final prefs = await SharedPreferences.getInstance();
    final cooldownEndTime = DateTime.now().millisecondsSinceEpoch + (_resendCooldown * 1000);
    await prefs.setInt(_cooldownKey, cooldownEndTime);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _resendCode() {
    _controller.clear();
    setState(() {
      correctCode = false;
      notCorrect = null;
    });

    // TODO ADD RESEND CODE LOGIC

    setState(() {
      _resendCooldown = 60;
    });

    _saveCooldownState();
    _startTimer();
  }

  void handleComplete(String code) {
    if (code != '123456') {
      setState(() {
        correctCode = false;
        notCorrect = 'رمز غير صالح. يرجى المحاولة مرة أخرى.';
      });
    } else {
      setState(() {
        correctCode = true;
        notCorrect = null;
      });
    }
  }

  void next() {
    if (correctCode) {
      widget.next();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(
        fontSize: 20,
        color: AppColors.primary,
        fontFamily: accentFont,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mutedSilver),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: AppColors.primaryAccent,
        border: Border.all(color: Colors.transparent),
      ),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        widget.prevs();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              widget.prevs();
            },
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: ListView(
              padding: const EdgeInsets.all(30.0),
              shrinkWrap: true,
              children: [
                const AppLogoWidget(),
                const SizedBox(height: 25),
                buildBody(submittedPinTheme, defaultPinTheme, focusedPinTheme),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 25),
          child: CustomButton(text: "متابعة", onPressed: next, fontSize: 16),
        ),
      ),
    );
  }

  Column buildBody(PinTheme submittedPinTheme, PinTheme defaultPinTheme, PinTheme focusedPinTheme) {
    final currentMetadata = ref.watch(localUserMetadata);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "تحقق من بريدك الإلكتروني",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            text:
                "لقد أرسلنا رمز مكون من 6 أرقام إلى بريدك الإلكتروني. يرجى إدخاله أدناه للتحقق من بريدك الإلكتروني.\n",
            children: [
              TextSpan(
                text: '${currentMetadata?.email}',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          style: TextStyle(
            fontFamily: arabicAccentFont,
            fontWeight: FontWeight.w200,
            color: Colors.white.withValues(alpha: .96),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Pinput(
          controller: _controller,
          length: 6,
          pinAnimationType: PinAnimationType.scale,
          submittedPinTheme: submittedPinTheme,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          onCompleted: handleComplete,
        ),
        const SizedBox(height: 30),

        if ((notCorrect != null && notCorrect!.isNotEmpty) && !correctCode) ...[
          Text(
            notCorrect!,
            style: TextStyle(
              fontFamily: arabicAccentFont,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.errorColor,
            ),
          ),
          const SizedBox(height: 20),
        ],

        if (correctCode && notCorrect == null) ...[
          Text(
            "رائع! تم تأكيد بريدك الإلكتروني. لنستمر.",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.greenColor,
              fontSize: 16,
              fontFamily: arabicAccentFont,
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (!correctCode)
          InkWell(
            onTap: _resendCooldown == 0 ? _resendCode : null,
            child: Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                text: "لم تستلم البريد الإلكتروني؟",
                children: [
                  TextSpan(
                    text:
                        _resendCooldown > 0
                            ? '\nإعادة إرسال الرمز في $_resendCooldown ثواني'
                            : '\nإعادة إرسال الرمز',
                    style: TextStyle(
                      color: _resendCooldown > 0 ? AppColors.mutedSilver : AppColors.primary,
                      decoration:
                          _resendCooldown > 0 ? TextDecoration.none : TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(
                    text: '\nتحقق من خانة الرسائل غير المرغوب فيها اذا لم يصلك',
                    style: TextStyle(fontSize: 15, color: AppColors.primary),
                  ),
                ],
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: arabicAccentFont,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }
}
