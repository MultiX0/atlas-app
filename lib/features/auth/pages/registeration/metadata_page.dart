import 'dart:developer';

import 'package:atlas_app/features/auth/controller/auth_controller.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:intl/intl.dart';

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
        fullName: _fullNameController.text.trim(),
        username: username,
        userId: "",
        avatar: emptyAvatar,
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
          child: CustomButton(text: "Continue", onPressed: next, isLoading: isLoading),
        ),
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              widget.prevs();
            },
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            children: [
              const Text(
                "Choose how you want to be seen\non Atlas!",
                style: TextStyle(fontFamily: accentFont, fontSize: 20),
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
    );
  }

  Column buildBirthdateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel("Birthdate", size: 15),
        CustomTextFormField(
          prefixIcon: LucideIcons.calendar,
          hintText: "Select Your Birthdate",
          controller: _birthDateController,
          readOnly: true,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'please select your birthdate';
            }
            return null;
          },
          onTap: birthDateSheet,
        ),
        buildLabel("(You must be 13+ to join.)"),
      ],
    );
  }

  Column buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel("Username", size: 15),
        CustomTextFormField(
          prefixIcon: LucideIcons.at_sign,
          hintText: "Enter Your username",
          controller: _usernameController,
          validator: (val) => validateUsername(val),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[a-z0-9_.]*$'))],
        ),
        if (isUsernameTaken) ...[
          buildLabel("This username is already in use. Try another!", color: AppColors.errorColor),
        ],
        buildLabel("(Your unique handle on Atlas. No spaces or special characters.)"),
      ],
    );
  }

  Column buildNicknameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel("Nickname", size: 15),
        CustomTextFormField(
          prefixIcon: LucideIcons.user,
          hintText: "Enter Your nickname",
          controller: _fullNameController,
          validator: (val) => validateNickname(val),
        ),
        buildLabel("(This name will be visible to others. Use your real name or a nickname!)"),
      ],
    );
  }

  String? validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Nickname cannot be empty.";
    }
    if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value)) {
      return "Nickname can only contain letters, numbers, and spaces.";
    }
    if (value.trim().length < 3 || value.trim().length > 10) {
      return "Nickname must be between 3 and 10 characters.";
    }
    return null; // Valid
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Username cannot be empty.";
    }
    if (value.length < 3 || value.length > 15) {
      return "Username must be between 3 and 15 characters.";
    }
    if (!RegExp(r'^[a-z0-9_.]+$').hasMatch(value)) {
      return "Username can only contain lowercase letters, numbers, underscores, and dots.";
    }
    if (RegExp(r'[_\.]{2,}').hasMatch(value)) {
      return "Username cannot have consecutive underscores or dots.";
    }
    if (value.startsWith('_') ||
        value.startsWith('.') ||
        value.endsWith('_') ||
        value.endsWith('.')) {
      return "Username cannot start or end with an underscore or dot.";
    }
    return null; // Valid
  }

  Widget buildLabel(String text, {double size = 14, Color color = AppColors.mutedSilver}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        child: Text(
          text,
          style: TextStyle(fontFamily: accentFont, fontSize: size, color: AppColors.mutedSilver),
        ),
      ),
    );
  }
}
