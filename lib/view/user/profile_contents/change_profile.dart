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
import 'package:roomdz_frontend/widget/role_badge.dart';
import 'package:roomdz_frontend/widget/modern_button_loader.dart';

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
  final TextEditingController _telegramCtrl = TextEditingController();
  final TextEditingController _locationTagCtrl = TextEditingController();
  final TextEditingController _bakongAccountCtrl = TextEditingController();
  final TextEditingController _bakongMerchantCtrl = TextEditingController();

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
    _telegramCtrl.dispose();
    _locationTagCtrl.dispose();
    _bakongAccountCtrl.dispose();
    _bakongMerchantCtrl.dispose();
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
        _telegramCtrl.text = localUser.telegram ?? '';
        _locationTagCtrl.text = localUser.locationTag ?? '';
        _bakongAccountCtrl.text = localUser.bakongAccountId ?? '';
        _bakongMerchantCtrl.text = localUser.bakongMerchantName ?? '';
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
          _telegramCtrl.text = remoteUser.telegram ?? '';
          _locationTagCtrl.text = remoteUser.locationTag ?? '';
          _bakongAccountCtrl.text = remoteUser.bakongAccountId ?? '';
          _bakongMerchantCtrl.text = remoteUser.bakongMerchantName ?? '';
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
      Get.snackbar(
        'Error',
        'មិនអាចជ្រើសរើសរូបភាពបានទេ',
        snackPosition: SnackPosition.TOP,
      );
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
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.primary,
              ),
              title: Text('ថតរូបភាព', style: GoogleFonts.battambang()),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                'ជ្រើសរើសពីវិចិត្រសាល',
                style: GoogleFonts.battambang(),
              ),
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
    final telegram = _telegramCtrl.text.trim();
    final locationTag = _locationTagCtrl.text.trim();
    final bakongAccount = _bakongAccountCtrl.text.trim();
    final bakongMerchant = _bakongMerchantCtrl.text.trim();

    if (name.isEmpty) {
      Get.snackbar('កំហុស', 'សូមបញ្ចូលឈ្មោះ', snackPosition: SnackPosition.TOP);
      return;
    }

    if (email.isEmpty) {
      Get.snackbar(
        'កំហុស',
        'សូមបញ្ចូលអ៊ីមែល',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _authService.updateProfile(
        name: name,
        phone: phone,
        email: email,
        telegram: telegram,
        locationTag: locationTag,
        bakongAccountId: bakongAccount,
        bakongMerchantName: bakongMerchant,
        avatarPath: _pickedImagePath,
      );

      // Sync with profile controller if registered
      if (Get.isRegistered<ProfileController>() && _pickedImagePath != null) {
        Get.find<ProfileController>().localAvatarPath.value = _pickedImagePath;
      }

      if (mounted) {
        Get.back(result: true);
        Get.snackbar(
          'ជោគជ័យ',
          'បានកែប្រែប្រវត្តិរូបដោយជោគជ័យ',
          backgroundColor: const Color(0xFFDCFCE7),
          colorText: const Color(0xFF16A34A),
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF16A34A),
          ),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'បរាជ័យ',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
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
                    RoleBadge(role: _user!.role!.name, fontSize: 13),

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

                        const SizedBox(height: 18),

                        // Telegram
                        _buildLabel('តេឡេក្រាម (Telegram)'),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _telegramCtrl,
                          hint: 'ឧ. @username ឬ https://t.me/...',
                          icon: Icons.send_rounded,
                        ),

                        const SizedBox(height: 18),

                        // Location Tag
                        _buildLabel('តំបន់ / ទីតាំង (Location)'),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _locationTagCtrl,
                          hint: 'ឧ. រាជធានីភ្នំពេញ, ខណ្ឌទួលគោក',
                          icon: Icons.location_on_outlined,
                        ),
                      ],
                    ),
                  ),

                  // Bakong KHQR Configuration for Owner
                  if (_user?.isOwner == true ||
                      (_user?.bakongAccountId != null &&
                          _user!.bakongAccountId!.isNotEmpty)) ...[
                    const SizedBox(height: 20),
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFDC2626,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.qr_code_2_rounded,
                                  color: Color(0xFFDC2626),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ការកំណត់បង់ប្រាក់បាគង (Bakong KHQR)',
                                      style: GoogleFonts.battambang(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      'សម្រាប់បង្កើតកូដ KHQR ទទួលប្រាក់កក់បន្ទប់',
                                      style: GoogleFonts.battambang(
                                        fontSize: 12,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFFD97706),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'សូមបញ្ចូលគណនីបាគងត្រឹមត្រូវ ដើម្បីឱ្យប្រព័ន្ធអាចបង្កើត QR កូដស្វ័យប្រវត្តិចំពោះការកក់បន្ទប់។',
                                    style: GoogleFonts.battambang(
                                      fontSize: 12,
                                      color: const Color(0xFF92400E),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Bakong Account ID
                          _buildLabel('លេខគណនីបាគង (Bakong Account ID)'),
                          const SizedBox(height: 8),
                          _buildInputField(
                            controller: _bakongAccountCtrl,
                            hint: 'ឧ. username@aclb ឬ 012345678@wing',
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                          const SizedBox(height: 18),
                          // Bakong Merchant Name
                          _buildLabel('ឈ្មោះម្ចាស់គណនី / ហាង (Merchant Name)'),
                          const SizedBox(height: 8),
                          _buildInputField(
                            controller: _bakongMerchantCtrl,
                            hint: 'ឧ. បន្ទប់ជួល វណ្ណៈ ឬ DARA APARTMENT',
                            icon: Icons.storefront_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],

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
                        disabledBackgroundColor: AppColors.primary,
                        disabledForegroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: ModernButtonContent(
                        isLoading: _isSaving,
                        text: 'រក្សាទុកការផ្លាស់ប្តូរ',
                        loadingText: 'កំពុងរក្សាទុក',
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
