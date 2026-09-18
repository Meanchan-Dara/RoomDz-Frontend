import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/controller/favorite_controller.dart';
import 'package:roomdz_frontend/controller/profile_controller.dart';
import 'package:roomdz_frontend/model/user_model.dart';
import 'package:roomdz_frontend/service/auth_service.dart';
import 'package:roomdz_frontend/service/database/database_service.dart';
import 'package:roomdz_frontend/view/own_room/my_rooms_screen.dart';
import 'package:roomdz_frontend/view/own_room/viewing_request_screen.dart';
import 'package:roomdz_frontend/view/user/favorateScreen.dart';
import 'package:roomdz_frontend/view/user/profile_contents/about_screen.dart';
import 'package:roomdz_frontend/view/user/profile_contents/change_profile.dart';
import 'package:roomdz_frontend/view/user/profile_contents/help_support_screen.dart';
import 'package:roomdz_frontend/view/user/profile_contents/language_screen.dart';
import 'package:roomdz_frontend/view/user/profile_contents/my_renting_screen.dart';
import 'package:roomdz_frontend/view/user/profile_contents/my_requests_screen.dart';
import 'package:roomdz_frontend/view/user/profile_contents/notifications_screen.dart';
import 'package:roomdz_frontend/view/user/profile_contents/search_preferences_screen.dart';
import 'package:roomdz_frontend/view/user/profile_contents/security_screen.dart';
import 'package:roomdz_frontend/view/user/signInScreen.dart';
import 'package:roomdz_frontend/widget/role_badge.dart';

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
  int _rentingCount = 0;
  int _contactedCount = 0;

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

    _favCtrl.loadFavorites();

    try {
      final res = await authService.getProfileWithStats();
      if (res != null && mounted) {
        final user = UserModel.fromJson(res['user']);
        final stats = res['stats'] as Map<String, dynamic>?;

        setState(() {
          currentUser = user;
          if (stats != null) {
            _rentingCount = (stats['renting_count'] as num?)?.toInt() ?? 0;
            _contactedCount =
                (stats['contacted_count'] as num?)?.toInt() ??
                (stats['inquiries_count'] as num?)?.toInt() ??
                0;
          }
        });
      }
    } catch (_) {}
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'ចាក់ចេញពីគណនី?',
              style: GoogleFonts.battambang(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'តើអ្នកពិតជាចង់ចាក់ចេញពីគណនី RoomDz នេះមែនទេ?',
          style: GoogleFonts.battambang(
            fontSize: 14,
            color: const Color(0xFF334155),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'ថយក្រោយ',
              style: GoogleFonts.battambang(color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await authService.logout();
              await DatabaseService.instance.clearUser();
              Get.offAll(() => const Signinscreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'ចាក់ចេញ',
              style: GoogleFonts.battambang(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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

      body: RefreshIndicator(
        onRefresh: _loadUser,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

                    // user name + role badge (tap to edit profile)
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final updated = await Get.to(
                          () => const ChangeProfile(),
                        );
                        if (updated == true) {
                          _loadUser();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              currentUser?.name ?? 'User Name',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (currentUser?.role?.name != null &&
                                currentUser!.role!.name.trim().isNotEmpty)
                              RoleBadge(role: currentUser!.role!.name),
                            const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.black12,
                    ),

                    const SizedBox(height: 16),

                    // statistics
                    Obx(() {
                      final favCount = _favCtrl.favoriteRoomIds.length;

                      return Row(
                        children: [
                          // favorite count
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                await Get.to(() => const FavoriteScreen());
                                _loadUser();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
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
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                if (currentUser?.role?.name == 'owner') {
                                  await Get.to(() => const MyRoomsScreen());
                                } else {
                                  await Get.to(() => const MyRentingScreen());
                                }
                                _loadUser();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '$_rentingCount',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
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
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                if (currentUser?.role?.name == 'owner') {
                                  await Get.to(
                                    () => const ViewingRequestScreen(),
                                  );
                                } else {
                                  await Get.to(() => const MyRequestsScreen());
                                }
                                _loadUser();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '$_contactedCount',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'បានទាក់ទង',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
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
                          }
                        },
                      ),

                      _buildMenuItem(
                        icon: Icons.favorite_border_rounded,
                        title: 'បន្ទប់ដែលបានរក្សាទុក',
                        onTap: () async {
                          await Get.to(() => const FavoriteScreen());
                          _loadUser();
                        },
                      ),

                      _buildMenuItem(
                        icon: Icons.list_alt_rounded,
                        title: 'សំណើរបស់ខ្ញុំ',
                        onTap: () async {
                          if (currentUser?.role?.name == 'owner') {
                            await Get.to(() => const ViewingRequestScreen());
                          } else {
                            await Get.to(() => const MyRequestsScreen());
                          }
                          _loadUser();
                        },
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // preferences
                    _buildMenuCard([
                      _buildMenuItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'ការជូនដំណឹង',
                        onTap: () => Get.to(() => const NotificationsScreen()),
                      ),

                      _buildMenuItem(
                        icon: Icons.tune_rounded,
                        title: 'ការកំណត់ស្វែងរក',
                        onTap: () =>
                            Get.to(() => const SearchPreferencesScreen()),
                      ),

                      _buildMenuItem(
                        icon: Icons.language_rounded,
                        title: 'ភាសា',
                        onTap: () => Get.to(() => const LanguageScreen()),
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // support and legal
                    _buildMenuCard([
                      _buildMenuItem(
                        icon: Icons.lock_outline_rounded,
                        title: 'ឯកជនភាព និងសុវត្ថិភាព',
                        onTap: () async {
                          final updated = await Get.to(
                            () => SecurityScreen(user: currentUser),
                          );
                          if (updated == true) {
                            _loadUser();
                          }
                        },
                      ),

                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'ជំនួយ និងការគាំទ្រ',
                        onTap: () => Get.to(() => const HelpSupportScreen()),
                      ),

                      _buildMenuItem(
                        icon: Icons.info_outline_rounded,
                        title: 'អំពី RoomDz',
                        onTap: () => Get.to(() => const AboutScreen()),
                        isLast: true,
                      ),
                    ]),
                  ],
                ),
              ),

              // logout
              GestureDetector(
                onTap: () => _confirmLogout(context),

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

              const SizedBox(height: 100),
            ],
          ),
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
