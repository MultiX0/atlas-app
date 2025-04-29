import 'dart:developer';

import 'package:atlas_app/features/auth/pages/registeration/email_page.dart';
import 'package:atlas_app/features/auth/pages/registeration/final_register_page.dart';
import 'package:atlas_app/features/auth/pages/registeration/metadata_page.dart';
import 'package:atlas_app/imports.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  late PageController _controller;
  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  void next() {
    log("next");
    _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  void prevs() {
    _controller.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: _controller,
      children: [
        EmailPage(next: next, prevs: prevs),
        // PinCodeConfirmPage(next: next, prevs: prevs),
        MetadataPage(next: next, prevs: prevs),
        FinalRegisterPage(next: next, prevs: prevs),
      ],
    );
  }
}
