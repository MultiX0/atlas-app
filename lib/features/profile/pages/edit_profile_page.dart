import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/image_picker.dart';
import 'package:atlas_app/features/profile/controller/profile_controller.dart';
import 'package:atlas_app/imports.dart';
import 'dart:io';

import 'package:flutter/services.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  File? _selectedAvatar;
  File? _selectedBanner;
  String? avatar;
  String? banner;

  @override
  void initState() {
    final me = ref.read(userState).user!;

    super.initState();
    _fullNameController = TextEditingController(text: me.fullName);
    _usernameController = TextEditingController(text: me.username);
    _bioController = TextEditingController(text: me.bio);
    avatar = me.avatar;
    banner = me.banner;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_usernameController.text.trim().length < 3) {
      CustomToast.error('اسم المستخدم يجب أن يكون أكثر من 3 حروف');
      return;
    }
    ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          fullName: _fullNameController.text.trim(),
          userName: _usernameController.text.toLowerCase().trim(),
          bio: _bioController.text.trim(),
          avatar: _selectedAvatar,
          banner: _selectedBanner,
          avatarUrl: avatar ?? "",
          bannerUrl: banner,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text("تعديل الملف الشخصي")),
      body: ListView(
        children: [
          EditHeader(
            avatarUrl: avatar!,
            bannerUrl: banner ?? "",
            selectedAvatar: _selectedAvatar,
            selectedBanner: _selectedBanner,
            onAvatarTap: () async {
              final pickedFile = await profilePhotoPicker(
                isAvatar: true,
                size: const Size(200, 200),
              );
              if (pickedFile != null) {
                setState(() {
                  _selectedAvatar = File(pickedFile.path);
                });
              }
            },
            onBannerTap: () async {
              final pickedFile = await profilePhotoPicker(
                size: Size(size.width / 2, size.width * .85),
              );
              if (pickedFile != null) {
                setState(() {
                  _selectedBanner = File(pickedFile.absolute.path);
                });
              }
            },
          ),
          EditBody(
            fullNameController: _fullNameController,
            usernameController: _usernameController,
            bioController: _bioController,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submit,
        backgroundColor: AppColors.primary.withValues(alpha: .5),
        child: Icon(Icons.done, color: AppColors.whiteColor),
      ),
    );
  }
}

class EditHeader extends StatelessWidget {
  final String avatarUrl;
  final String bannerUrl;
  final File? selectedAvatar;
  final File? selectedBanner;
  final VoidCallback onAvatarTap;
  final VoidCallback onBannerTap;

  const EditHeader({
    super.key,
    required this.avatarUrl,
    required this.bannerUrl,
    this.selectedAvatar,
    this.selectedBanner,
    required this.onAvatarTap,
    required this.onBannerTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.width * 0.45,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double bannerHeight = constraints.maxWidth * 5 / 16;
          const double avatarSize = 70;

          return Stack(
            children: [
              GestureDetector(
                onTap: onBannerTap,
                child: SizedBox(
                  height: bannerHeight,
                  width: constraints.maxWidth,
                  child:
                      selectedBanner != null
                          ? Image.file(selectedBanner!, fit: BoxFit.cover)
                          : (bannerUrl.isNotEmpty
                              ? CachedNetworkImage(
                                imageUrl: bannerUrl,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Container(
                                      color: AppColors.textFieldFillColor,
                                      child: const Center(
                                        child: Text(
                                          "صورة العرض (البنر)",
                                          style: TextStyle(fontFamily: arabicAccentFont),
                                        ),
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Container(
                                      color: AppColors.textFieldFillColor,
                                      child: const Center(
                                        child: Text(
                                          "صورة العرض (البنر)",
                                          style: TextStyle(fontFamily: arabicAccentFont),
                                        ),
                                      ),
                                    ),
                              )
                              : Container(
                                color: AppColors.textFieldFillColor,
                                child: const Center(
                                  child: Text(
                                    "صورة العرض (البنر)",
                                    style: TextStyle(fontFamily: arabicAccentFont),
                                  ),
                                ),
                              )),
                ),
              ),
              Positioned(
                bottom: 20,
                left: (constraints.maxWidth / 2) - (avatarSize * 2.5),
                child: GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      color: AppColors.textFieldFillColor,
                      border: Border.all(
                        color: Colors.white,
                        strokeAlign: BorderSide.strokeAlignInside * 4,
                      ),
                    ),
                    child:
                        selectedAvatar != null
                            ? Image.file(selectedAvatar!, fit: BoxFit.cover)
                            : (avatarUrl.isNotEmpty
                                ? CachedNetworkImage(
                                  imageUrl: avatarUrl,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => const Center(
                                        child: Text(
                                          "الأفتار",
                                          style: TextStyle(fontFamily: arabicAccentFont),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => const Center(
                                        child: Text(
                                          "الأفتار",
                                          style: TextStyle(fontFamily: arabicAccentFont),
                                        ),
                                      ),
                                )
                                : const Center(
                                  child: Text(
                                    "الأفتار",
                                    style: TextStyle(fontFamily: arabicAccentFont),
                                  ),
                                )),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class EditBody extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController usernameController;
  final TextEditingController bioController;

  const EditBody({
    super.key,
    required this.fullNameController,
    required this.usernameController,
    required this.bioController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: "الاسم الكامل",
                labelStyle: const TextStyle(
                  fontFamily: arabicAccentFont,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
                hintText: "أدخل اسمك هنا",
                hintStyle: const TextStyle(fontFamily: arabicAccentFont),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
                fillColor: AppColors.textFieldFillColor,
                border: InputBorder.none,
                enabledBorder: const UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[300]!),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TextField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[a-z0-9_.]*$'))],
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "اسم المستخدم",
                labelStyle: const TextStyle(
                  fontFamily: arabicAccentFont,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
                hintText: "أدخل اسم المستخدم الخاص بك",
                hintStyle: const TextStyle(fontFamily: arabicAccentFont),
                prefixIcon: const Icon(LucideIcons.at_sign, color: AppColors.mutedSilver),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
                fillColor: AppColors.textFieldFillColor,
                border: InputBorder.none,
                enabledBorder: const UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[300]!),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade900),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade900),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TextField(
              controller: bioController,
              minLines: 1,
              maxLength: 150,
              maxLines: null,
              decoration: InputDecoration(
                labelText: "البايو",
                labelStyle: const TextStyle(
                  fontFamily: arabicAccentFont,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
                hintStyle: const TextStyle(fontFamily: arabicAccentFont),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
                hintText: "النبذة التعريفية",
                fillColor: AppColors.textFieldFillColor,
                border: InputBorder.none,
                enabledBorder: const UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[300]!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
