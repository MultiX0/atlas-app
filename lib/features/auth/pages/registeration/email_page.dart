import 'package:atlas_app/features/auth/models/user_metadata.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/services.dart';

class EmailPage extends ConsumerStatefulWidget {
  const EmailPage({super.key, required this.next, required this.prevs});

  final VoidCallback next;
  final VoidCallback prevs;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EmailPageState();
}

class _EmailPageState extends ConsumerState<EmailPage> {
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void next() {
    if (_formKey.currentState!.validate()) {
      ref.read(localUserMetadata.notifier).state = UserMetadata(
        salt: "",
        email: _emailController.text.trim(),
        password: '',
        birthDate: DateTime.now(),
        userId: '',
      );
      widget.next();
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 25),
        child: CustomButton(text: "Continue", onPressed: next),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          children: [
            const Text(
              "Your journey with Atlas starts here!",
              style: TextStyle(fontFamily: accentFont, fontSize: 20),
            ),
            const SizedBox(height: 20),
            CustomTextFormField(
              contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
              controller: _emailController,
              hintText: "Please enter your real email to continue.",
              prefixIcon: LucideIcons.mail,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9.@_\-+]'))],
              validator: (val) => emailValidator(val),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                child: Text(
                  "This will be used for account security and future updates.",
                  style: TextStyle(
                    fontFamily: accentFont,
                    fontSize: 13,
                    color: AppColors.mutedSilver,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? emailValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'please enter your email';
    }

    if (val.length < 4) {
      return 'please enter valid email address';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(val)) {
      return 'Please enter a valid email address';
    }

    return null;
  }
}
