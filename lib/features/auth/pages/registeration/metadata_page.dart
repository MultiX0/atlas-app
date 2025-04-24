import 'dart:developer';

import 'package:atlas_app/features/auth/controller/auth_controller.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class MetadataPage extends ConsumerStatefulWidget {
  const MetadataPage({super.key, required this.next, required this.prevs});

  final VoidCallback next;
  final VoidCallback prevs;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MetadataPageState();
}

class _MetadataPageState extends ConsumerState<MetadataPage> {
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _birthDateController;
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;

  bool isUsernameTaken = false;

  @override
  void initState() {
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _birthDateController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _fullNameController.clear();
    _usernameController.clear();
    _birthDateController.clear();
    super.dispose();
  }

  void birthDateSheet() {
    picker.DatePicker.showDatePicker(
      context,
      theme: picker.DatePickerTheme(
        backgroundColor: AppColors.scaffoldBackground,
        itemStyle: TextStyle(color: AppColors.whiteColor),
        cancelStyle: const TextStyle(color: Colors.white60),
      ),
      showTitleActions: true,
      maxTime: DateTime.now().subtract(const Duration(days: 365 * 14)),
      onChanged: (date) {
        final d = DateFormat.yMMMMd('en_US').format(date);
        log(d);
        setState(() {
          _birthDateController.text = d;
          selectedDate = date;
        });
      },
      onConfirm: (date) {
        final d = DateFormat.yMMMMd('en_US').format(date);
        log(d);
        setState(() {
          _birthDateController.text = d;
          selectedDate = date;
        });
      },
      currentTime: DateTime.now(),
      locale: picker.LocaleType.en,
    );
  }

  void next() async {
    if (isUsernameTaken) {
      setState(() {
        isUsernameTaken = false;
      });
    }

    if (_formKey.currentState!.validate()) {
      final localMetaData = ref.read(localUserMetadata);
      ref.read(localUserMetadata.notifier).state = localMetaData!.copyWith(birthDate: selectedDate);
      final username = _usernameController.text.trim();
      ref.read(localUserModel.notifier).state = UserModel(
        followers_count: 0,
        following_count: 0,
        postsCount: 0,
        fullName: _fullNameController.text.trim(),
        username: username,
        userId: "",
        avatar: emptyAvatar,
        banner: emptyBanner,
        metadata: localMetaData.copyWith(birthDate: selectedDate),
      );

      final isTaken = await ref.read(authControllerProvider.notifier).isUsernameTaken(username);
      if (isTaken) {
        setState(() {
          isUsernameTaken = isTaken;
        });
        return;
      }

      widget.next();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        widget.prevs();
      },
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 25),
          child: CustomButton(text: "متابعة", onPressed: next, isLoading: isLoading, fontSize: 16),
        ),
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              widget.prevs();
            },
          ),
        ),
        body: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              children: [
                const Text(
                  "اختر كيف تريد أن تُرى على أطلس!",
                  style: TextStyle(fontFamily: arabicAccentFont, fontSize: 24),
                ),
                const SizedBox(height: Spacing.normalGap),
                buildNicknameField(),
                const SizedBox(height: Spacing.normalGap),
                buildUsernameField(),
                const SizedBox(height: Spacing.normalGap),
                buildBirthdateField(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column buildBirthdateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel("تاريخ الميلاد", size: 15),
        CustomTextFormField(
          prefixIcon: LucideIcons.calendar,
          hintText: "اختر تاريخ ميلادك",
          controller: _birthDateController,
          readOnly: true,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'يرجى اختيار تاريخ ميلادك';
            }
            return null;
          },
          onTap: birthDateSheet,
        ),
        buildLabel("(يجب أن تكون في سن 14 أو أكثر للانضمام.)"),
      ],
    );
  }

  Column buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel("اسم المستخدم", size: 15),
        CustomTextFormField(
          prefixIcon: LucideIcons.at_sign,
          hintText: "أدخل اسم المستخدم الخاص بك",
          controller: _usernameController,
          validator: (val) => validateUsername(val),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[a-z0-9_.]*$'))],
        ),
        if (isUsernameTaken) ...[
          buildLabel(
            "اسم المستخدم هذا قيد الاستخدام بالفعل. جرب اسمًا آخر!",
            color: AppColors.errorColor,
          ),
        ],
        buildLabel("(معرفك الفريد على أطلس. لا مسافات أو رموز خاصة.)"),
      ],
    );
  }

  Column buildNicknameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel("الاسم الشخصي", size: 15),
        CustomTextFormField(
          prefixIcon: LucideIcons.user,
          hintText: "أدخل اسم مستعارك",
          controller: _fullNameController,
          validator: (val) => validateNickname(val),
        ),
        buildLabel("(سيكون هذا الاسم مرئيًا للآخرين. استخدم اسمك الحقيقي أو لقبًا!)"),
      ],
    );
  }

  String? validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "اللقب لا يمكن أن يكون فارغًا.";
    }
    if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value)) {
      return "اللقب يمكن أن يحتوي فقط على الحروف، الأرقام، والمسافات.";
    }
    if (value.trim().length < 3 || value.trim().length > 10) {
      return "يجب أن يكون اللقب بين 3 و 10 أحرف.";
    }
    return null; // Valid
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "اسم المستخدم لا يمكن أن يكون فارغًا.";
    }
    if (value.length < 3 || value.length > 15) {
      return "يجب أن يكون اسم المستخدم بين 3 و 15 حرفًا.";
    }
    if (!RegExp(r'^[a-z0-9_.]+$').hasMatch(value)) {
      return "اسم المستخدم يمكن أن يحتوي فقط على الحروف الصغيرة، الأرقام، العلامات السفلية (_)، والنقاط (.).";
    }
    if (RegExp(r'[_\.]{2,}').hasMatch(value)) {
      return "اسم المستخدم لا يمكن أن يحتوي على شرطات سفلية أو نقاط متتالية.";
    }
    if (value.startsWith('_') ||
        value.startsWith('.') ||
        value.endsWith('_') ||
        value.endsWith('.')) {
      return "اسم المستخدم لا يمكن أن يبدأ أو ينتهي بشرطة سفلية أو نقطة.";
    }
    return null; // Valid
  }

  Widget buildLabel(String text, {double size = 14, Color color = AppColors.mutedSilver}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: arabicAccentFont,
            fontSize: size,
            color: AppColors.mutedSilver,
          ),
        ),
      ),
    );
  }
}
