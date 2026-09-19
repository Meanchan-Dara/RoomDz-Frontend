import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:roomdz_frontend/widget/app_alert.dart';

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final _storage = const FlutterSecureStorage();

  // selected local avatar path
  final RxnString localAvatarPath = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadAvatarPath();
  }

  Future<void> _loadAvatarPath() async {
    final savedPath = await _storage.read(key: 'avatar_path');
    if (savedPath != null) {
      localAvatarPath.value = savedPath;
    }
  }

  // show avatar picker
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
            if (localAvatarPath.value != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'លុបរូបភាព',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  removeAvatar();
                },
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // pick image
  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked != null) {
        localAvatarPath.value = picked.path;
        await _storage.write(key: 'avatar_path', value: picked.path);
      }
    } catch (e) {
      AppAlert.error('បរាជ័យ', 'មិនអាចជ្រើសរើសរូបភាពបានទេ');
    }
  }

  // remove local avatar
  Future<void> removeAvatar() async {
    localAvatarPath.value = null;
    await _storage.delete(key: 'avatar_path');
  }
}
