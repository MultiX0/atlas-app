import 'dart:async';

import 'package:atlas_app/imports.dart';

class ConfirmEmailPage extends ConsumerStatefulWidget {
  const ConfirmEmailPage({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends ConsumerState<ConfirmEmailPage> {
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
        notCorrect = 'Invalid code. Please try again.';
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
      context.pushReplacement("${Routes.updatePasswordPage}/f");
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
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Your Reset Code")),
      body: Center(
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 25),
        child: CustomButton(text: "Continue", onPressed: next),
      ),
    );
  }

  Column buildBody(PinTheme submittedPinTheme, PinTheme defaultPinTheme, PinTheme focusedPinTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Verify Your Email",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            text:
                "We've sent a 6-digit code to your email. Please enter it below to verify your email.\n",
            children: [
              TextSpan(
                text: widget.email,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          style: TextStyle(fontWeight: FontWeight.w200, color: Colors.white.withValues(alpha: .65)),
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
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.errorColor),
          ),
          const SizedBox(height: 20),
        ],

        if (correctCode && notCorrect == null) ...[
          Text(
            "Great! Your email is confirmed. Let's continue.",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.greenColor),
          ),
          const SizedBox(height: 20),
        ],
        if (!correctCode)
          InkWell(
            onTap: _resendCooldown == 0 ? _resendCode : null,
            child: Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                text: "Didn't receive the email?",
                children: [
                  TextSpan(
                    text:
                        _resendCooldown > 0
                            ? '\nResend code in $_resendCooldown seconds'
                            : '\nResend code',
                    style: TextStyle(
                      fontSize: 13,
                      color: _resendCooldown > 0 ? AppColors.mutedSilver : AppColors.primary,
                      decoration:
                          _resendCooldown > 0 ? TextDecoration.none : TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(
                    text: '\nCheck your spam folder.',
                    style: TextStyle(fontSize: 13, color: AppColors.primary),
                  ),
                ],
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: accentFont,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }
}
