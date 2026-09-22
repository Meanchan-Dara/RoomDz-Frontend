import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:roomdz_frontend/features/auth/data/models/user_model.dart';
import 'package:roomdz_frontend/features/auth/data/services/auth_service.dart';
import 'package:roomdz_frontend/core/database/database_service.dart';
import 'package:roomdz_frontend/core/widgets/app_alert.dart';

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

  // selected local avatar path
  final RxnString localAvatarPath = RxnString();
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isUploadingAvatar = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAvatarPath();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final user = await DatabaseService.instance.getSavedUser();
      if (user != null) {
        currentUser.value = user;
      }
    } catch (_) {}
  }

  Future<void> _loadAvatarPath() async {
    try {
      final savedPath = await _storage.read(key: 'avatar_path');
      if (savedPath != null) {
        if (File(savedPath).existsSync()) {
          localAvatarPath.value = savedPath;
        } else {
          await _storage.delete(key: 'avatar_path');
        }
      }
    } catch (_) {}
  }

  // update local path & storage
  Future<void> updateAvatarPath(String? path) async {
    localAvatarPath.value = path;
    try {
      if (path != null && path.isNotEmpty) {
        await _storage.write(key: 'avatar_path', value: path);
      } else {
        await _storage.delete(key: 'avatar_path');
      }
    } catch (_) {}
  }

  // show avatar picker bottom sheet
  void showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),

            // top handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 16),

            // camera
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('ថតរូបភាព'),
              onTap: () async {
                Get.back();
                await pickImage(ImageSource.camera);
              },
            ),

            // gallery
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('ជ្រើសរើសពីម៉ាស៊ីន'),
              onTap: () async {
                Get.back();
                await pickImage(ImageSource.gallery);
              },
            ),

            // delete avatar
            if (localAvatarPath.value != null ||
                (currentUser.value?.avatar != null &&
                    currentUser.value!.avatar!.isNotEmpty))
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'លុបរូបភាព',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Get.back();
                  await removeAvatar();
                },
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // pick image and sync across app and server
  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked != null) {
        await updateAvatarPath(picked.path);

        // Upload to server and update SQLite user
        try {
          isUploadingAvatar.value = true;
          final updatedUser = await _authService.updateProfile(
            avatarPath: picked.path,
          );
          currentUser.value = updatedUser;
          await DatabaseService.instance.saveUser(updatedUser);
        } catch (e) {
          debugPrint('Sync avatar to server error: $e');
        } finally {
          isUploadingAvatar.value = false;
        }
      }
    } catch (e) {
      AppAlert.error('បរាជ័យ', 'មិនអាចជ្រើសរើសរូបភាពបានទេ');
    }
  }

  // remove local avatar and clear storage
  Future<void> removeAvatar() async {
    await updateAvatarPath(null);
    if (currentUser.value != null) {
      currentUser.value = UserModel(
        id: currentUser.value!.id,
        name: currentUser.value!.name,
        email: currentUser.value!.email,
        phone: currentUser.value!.phone,
        avatar: null,
        isVerified: currentUser.value!.isVerified,
        telegram: currentUser.value!.telegram,
        locationTag: currentUser.value!.locationTag,
        bakongAccountId: currentUser.value!.bakongAccountId,
        bakongMerchantName: currentUser.value!.bakongMerchantName,
        role: currentUser.value!.role,
      );
      await DatabaseService.instance.saveUser(currentUser.value!);
    }
  }
}
