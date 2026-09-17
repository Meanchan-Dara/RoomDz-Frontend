import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/controller/profile_controller.dart';
import 'package:roomdz_frontend/model/user_model.dart';
import 'package:roomdz_frontend/service/auth_service.dart';
import 'package:roomdz_frontend/service/database/database_service.dart';

class ChangeProfile extends StatefulWidget {
  const ChangeProfile({super.key});

  @override
  State<ChangeProfile> createState() => _ChangeProfileState();
}

class _ChangeProfileState extends State<ChangeProfile> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  UserModel? _user;
  String? _pickedImagePath;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    // First load from local SQLite
    final localUser = await DatabaseService.instance.getSavedUser();
    if (localUser != null && mounted) {
      setState(() {
        _user = localUser;
        _nameCtrl.text = localUser.name;
        _phoneCtrl.text = localUser.phone ?? '';
        _emailCtrl.text = localUser.email;
        _isLoading = false;
      });
    }

    // Then fetch fresh profile from API
    try {
      final remoteUser = await _authService.getProfile();
      if (remoteUser != null && mounted) {
        setState(() {
          _user = remoteUser;
          _nameCtrl.text = remoteUser.name;
          _phoneCtrl.text = remoteUser.phone ?? '';
          _emailCtrl.text = remoteUser.email;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() {
          _pickedImagePath = picked.path;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'មិនអាចជ្រើសរើសរូបភាពបានទេ');
    }
  }

  void _showImagePickerSheet() {
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
            const SizedBox(height: 12),
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
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
              title: Text('ថតរូបភាព', style: GoogleFonts.battambang()),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: Text('ជ្រើសរើសពីវិចិត្រសាល', style: GoogleFonts.battambang()),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_pickedImagePath != null || _user?.avatar != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  'លុបរូបភាព',
                  style: GoogleFonts.battambang(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  setState(() => _pickedImagePath = null);
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty) {
      Get.snackbar('កំហុស', 'សូមបញ្ចូលឈ្មោះ');
      return;
    }

    if (email.isEmpty) {
      Get.snackbar('កំហុស', 'សូមបញ្ចូលអ៊ីមែល');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _authService.updateProfile(
        name: name,
        phone: phone,
        email: email,
        avatarPath: _pickedImagePath,
      );

      // Sync with profile controller if registered
      if (Get.isRegistered<ProfileController>() && _pickedImagePath != null) {
        Get.find<ProfileController>().localAvatarPath.value = _pickedImagePath;
      }

      Get.snackbar(
        'ជោគជ័យ',
        'បានកែប្រែប្រវត្តិរូបដោយជោគជ័យ',
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF16A34A),
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'បរាជ័យ',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  ImageProvider _resolveAvatarImage() {
    if (_pickedImagePath != null) {
      return FileImage(File(_pickedImagePath!));
    }
    if (_user?.avatar != null && _user!.avatar!.isNotEmpty) {
      return CachedNetworkImageProvider(_user!.avatar!);
    }
    return const AssetImage('assets/images/logo.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'កែប្រែប្រវត្តិរូប',
          style: GoogleFonts.battambang(
            color: AppColors.neutral,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar with Camera icon
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _resolveAvatarImage(),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Material(
                            color: AppColors.primary,
                            shape: const CircleBorder(),
                            elevation: 4,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _showImagePickerSheet,
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Role Badge
                  if (_user?.role?.name != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _user!.role!.name.toUpperCase(),
                        style: GoogleFonts.battambang(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),

                  // Form Fields Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        _buildLabel('ឈ្មោះពេញ'),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _nameCtrl,
                          hint: 'បញ្ចូលឈ្មោះពេញរបស់អ្នក',
                          icon: Icons.person_outline,
                        ),

                        const SizedBox(height: 18),

                        // Phone
                        _buildLabel('លេខទូរស័ព្ទ'),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _phoneCtrl,
                          hint: 'បញ្ចូលលេខទូរស័ព្ទ (+855 ...)',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 18),

                        // Email
                        _buildLabel('អ៊ីមែល'),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _emailCtrl,
                          hint: 'បញ្ចូលអាសយដ្ឋានអ៊ីមែល',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'រក្សាទុកការផ្លាស់ប្តូរ',
                              style: GoogleFonts.battambang(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.battambang(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF334155),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.battambang(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.battambang(
          color: const Color(0xFF94A3B8),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
