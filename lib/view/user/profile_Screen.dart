import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/controller/favorite_controller.dart';
import 'package:roomdz_frontend/controller/profile_controller.dart';
import 'package:roomdz_frontend/service/auth_service.dart';
import 'package:roomdz_frontend/model/user_model.dart';
import 'package:roomdz_frontend/service/database/database_service.dart';
import 'package:roomdz_frontend/view/user/profile_contents/change_profile.dart';
import 'package:roomdz_frontend/view/user/signInScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();

  final FavoriteController _favCtrl = Get.find<FavoriteController>();

  final ProfileController _profileCtrl = Get.put(ProfileController());

  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // load saved user and sync with API
  Future<void> _loadUser() async {
    final localUser = await DatabaseService.instance.getSavedUser();
    if (mounted) {
      setState(() {
        currentUser = localUser;
      });
    }

    try {
      final remoteUser = await authService.getProfile();
      if (remoteUser != null && mounted) {
        setState(() {
          currentUser = remoteUser;
        });
      }
    } catch (_) {}
  }

  // build profile screen
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
            // profile information card
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
                  // avatar
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

                        child: Obx(() {
                          return CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.grey.shade200,

                            backgroundImage: _getAvatarImage(),
                          );
                        }),
                      ),

                      // camera button
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Material(
                          color: AppColors.secondary,
                          shape: const CircleBorder(),
                          elevation: 3,

                          child: InkWell(
                            customBorder: const CircleBorder(),

                            // call controller
                            onTap: () {
                              _profileCtrl.showAvatarPicker(context);
                            },

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

                  // user name
                  Text(
                    currentUser?.name ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // phone or email
                  Text(
                    currentUser?.phone ?? currentUser?.email ?? '0123456789',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 8),

                  // location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.email,
                        size: 16,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        currentUser?.email ?? 'User email',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  // Telegram if available
                  if (currentUser?.telegram != null &&
                      currentUser!.telegram!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.send_rounded,
                          size: 15,
                          color: Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          currentUser!.telegram!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0284C7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Bakong KHQR for Owner
                  if (currentUser?.isOwner == true &&
                      currentUser?.bakongAccountId != null &&
                      currentUser!.bakongAccountId!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.qr_code_2_rounded,
                            size: 15,
                            color: Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Bakong KHQR: ${currentUser!.bakongAccountId!}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  const Divider(height: 1, thickness: 1, color: Colors.black12),

                  const SizedBox(height: 16),

                  // statistics
                  Obx(() {
                    final favCount = _favCtrl.favoriteRoomIds.length;

                    return Row(
                      children: [
                        // favorite count
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

                        // divider
                        Container(
                          height: 40,
                          width: 1,
                          color: const Color(0xFFE2E8F0),
                        ),

                        // renting status
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

                        // divider
                        Container(
                          height: 40,
                          width: 1,
                          color: const Color(0xFFE2E8F0),
                        ),

                        // contact status
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

            // profile menu
            Padding(
              padding: const EdgeInsets.all(16.0),

              child: Column(
                children: [
                  // account
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'កែប្រែប្រវត្តិរូប',
                      onTap: () async {
                        final updated = await Get.to(
                          () => const ChangeProfile(),
                        );
                        if (updated == true) {
                          _loadUser();
                          Get.snackbar(
                            'ជោគជ័យ',
                            'បានកែប្រែប្រវត្តិរូបរួចរាល់',
                            backgroundColor: const Color(0xFFDCFCE7),
                            colorText: const Color(0xFF16A34A),
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF16A34A),
                            ),
                            snackPosition: SnackPosition.TOP,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                            duration: const Duration(seconds: 2),
                          );
                        }
                      },
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

                  // preferences
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

                  // support and legal
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

            // logout
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

  // return avatar image
  ImageProvider _getAvatarImage() {
    final localPath = _profileCtrl.localAvatarPath.value;

    // local selected image
    if (localPath != null) {
      return FileImage(File(localPath));
    }

    // saved user avatar
    if (currentUser?.avatar != null && currentUser!.avatar!.isNotEmpty) {
      return NetworkImage(currentUser!.avatar!);
    }

    // default avatar
    return const NetworkImage(
      'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
    );
  }

  // card container
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

  // menu item
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

            child: Icon(icon, color: const Color(0xFF1D4ED8), size: 20),
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
