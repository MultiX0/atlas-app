import 'dart:developer';

import 'package:atlas_app/imports.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => handleNext());
  }

  Future<void> handleNext() async {
    log("---------- test ----------");

    final userStateValue = ref.read(userState);
    final isUserLoggedIn = userStateValue.user != null;
    log(isUserLoggedIn.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const LinesPattren(),
          SafeArea(
            child: Center(
              child: AvifImage.asset('assets/images/logo_transparent.avif', width: 600),
            ),
          ),
        ],
      ),
    );
  }
}
