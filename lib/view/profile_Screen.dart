import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/controller/favorite_controller.dart';
import 'package:roomdz_frontend/service/auth_service.dart';
import 'package:roomdz_frontend/model/user_model.dart';
import 'package:roomdz_frontend/service/database/database_service.dart';
import 'package:roomdz_frontend/view/signInScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  final FavoriteController _favCtrl = Get.find<FavoriteController>();

  // Local avatar path – null means show the default network image
  String? _localAvatarPath;
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await DatabaseService.instance.getSavedUser();
    if (mounted) {
      setState(() {
        currentUser = user;
      });
    }
  }

  // ── Avatar picker ──────────────────────────────────────────────────────────
  Future<void> _pickAvatar() async {
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('ថតរូបភាព'),
              onTap: () async {
                Get.back();
                await _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('ជ្រើសរើសពីម៉ាស៊ីន'),
              onTap: () async {
                Get.back();
                await _pickImage(ImageSource.gallery);
              },
            ),
            if (_localAvatarPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'លុបរូបភាព',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  setState(() => _localAvatarPath = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _localAvatarPath = picked.path);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgsf,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Dz-Room',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ── Avatar with image-picker button ────────────────────
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _localAvatarPath != null
                              ? FileImage(File(_localAvatarPath!))
                              : (currentUser?.avatar != null
                                  ? NetworkImage(currentUser!.avatar!)
                                  : const NetworkImage(
                                      'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                                    )) as ImageProvider,
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Material(
                          color: AppColors.secondary,
                          shape: const CircleBorder(),
                          elevation: 3,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _pickAvatar,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // name of user
                  Text(
                    currentUser?.name ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser?.phone ?? currentUser?.email ?? '0123456789',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.deepOrange,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Boeung kengk kang, Phnom penh',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: Colors.black12),
                  const SizedBox(height: 16),

                  // Stats row – favourite count is live from FavoriteController
                  Obx(() {
                    final favCount = _favCtrl.favoriteRoomIds.length;
                    return Row(
                      children: [
                        // liked
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '$favCount',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'បន្ទប់ចូលចិត្ត',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          height: 40,
                          width: 1,
                          color: const Color(0xFFE2E8F0),
                        ),

                        // status of rent
                        Expanded(
                          child: Column(
                            children: const [
                              Text(
                                '8',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'កំពុងជួល',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          height: 40,
                          width: 1,
                          color: const Color(0xFFE2E8F0),
                        ),

                        // status of contact
                        Expanded(
                          child: Column(
                            children: const [
                              Text(
                                '5',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'បានទាក់ទងរ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // option of profile page
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- CARD 1: USER ACCOUNT ---
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'កែប្រែប្រវត្តិរូប',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.favorite_border_rounded,
                      title: 'បន្ទប់ដែលបានរក្សាទុក',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.list_alt_rounded,
                      title: 'សំណើរបស់ខ្ញុំ',
                      onTap: () {},
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // --- CARD 2: PREFERENCES ---
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'ការជូនដំណឹង',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.tune_rounded,
                      title: 'ការកំណត់ស្វែងរក',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.language_rounded,
                      title: 'ភាសា',
                      onTap: () {},
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // --- CARD 3: SUPPORT & LEGAL ---
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.lock_outline_rounded,
                      title: 'ឯកជនភាព និងសុវត្ថិភាព',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'ជំនួយ និងការគាំទ្រ',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline_rounded,
                      title: 'អំពី RoomFinder',
                      onTap: () {},
                      isLast: true,
                    ),
                  ]),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                await authService.logout();
                await DatabaseService.instance.clearUser();
                Get.off(() => Signinscreen());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'ចាក់ចេញពីគណនី',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Card Container Helper
  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // Single Menu Item Helper
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1D4ED8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1D4ED8),
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          onTap: onTap,
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFFE2E8F0),
          ),
      ],
    );
  }
}
