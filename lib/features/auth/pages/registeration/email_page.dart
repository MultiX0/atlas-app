import 'package:atlas_app/features/auth/controller/auth_controller.dart';
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
  bool emailTaken = false;
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

  void next() async {
    if (emailTaken) {
      setState(() {
        emailTaken = false;
      });
    }

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      ref.read(localUserMetadata.notifier).state = UserMetadata(
        salt: "",
        email: email,
        password: '',
        birthDate: DateTime.now(),
        userId: '',
      );

      final isTaken = await ref.read(authControllerProvider.notifier).isEmailTaken(email);
      if (isTaken) {
        setState(() {
          emailTaken = true;
        });
        return;
      }

      widget.next();
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 25),
        child: CustomButton(
          text: "متابعة",
          onPressed: next,
          fontSize: 16,
          // disabled: isLoading,
          isLoading: isLoading,
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            children: [
              const Text(
                "رحلتك مع أطلس تبدأ من هنا!",
                style: TextStyle(fontFamily: arabicAccentFont, fontSize: 24),
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                controller: _emailController,
                hintText: "يرجى إدخال بريدك الإلكتروني.",
                prefixIcon: LucideIcons.mail,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9.@_\-+]'))],
                validator: (val) => emailValidator(val),
              ),
              const SizedBox(height: 15),
              if (emailTaken) ...[buildEmailTakenAlert()],
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  child: const Text(
                    "سيُستخدم هذا لأمان الحساب والتحديثات المستقبلية.",
                    style: TextStyle(
                      fontFamily: arabicAccentFont,
                      fontSize: 13,
                      color: AppColors.mutedSilver,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding buildEmailTakenAlert() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        child: Text(
          "هذا البريد الإلكتروني مسجل بالفعل في أطلس!",
          style: TextStyle(
            fontFamily: arabicAccentFont,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.errorColor,
          ),
        ),
      ),
    );
  }

  String? emailValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'يرجى إدخال بريدك الإلكتروني';
    }

    if (val.length < 4) {
      return 'يرجى إدخال عنوان بريد إلكتروني صالح';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(val)) {
      return 'يرجى إدخال عنوان بريد إلكتروني صالح';
    }

    return null;
  }
}
