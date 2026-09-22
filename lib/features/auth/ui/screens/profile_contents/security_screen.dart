import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomdz_frontend/core/constants/app_colors.dart';
import 'package:roomdz_frontend/features/auth/data/models/user_model.dart';
import 'package:roomdz_frontend/core/network/api_client.dart';
import 'package:roomdz_frontend/features/auth/data/services/auth_service.dart';
import 'package:roomdz_frontend/core/database/database_service.dart';
import 'package:roomdz_frontend/core/widgets/role_badge.dart';
import 'package:roomdz_frontend/core/widgets/app_alert.dart';
import 'package:roomdz_frontend/core/widgets/modern_button_loader.dart';

class SecurityScreen extends StatefulWidget {
  final UserModel? user;

  const SecurityScreen({super.key, this.user});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    // 1. Get from local DB first
    final localUser = await DatabaseService.instance.getSavedUser();
    if (localUser != null && mounted) {
      setState(() => _currentUser = localUser);
    }

    // 2. Fetch fresh user data from API
    try {
      final remoteUser = await _authService.getProfile();
      if (remoteUser != null && mounted) {
        setState(() => _currentUser = remoteUser);
      }
    } catch (_) {}
  }

  void _showChangePasswordDialog() {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isObscureCurrent = true;
    bool isObscureNew = true;
    bool isObscureConfirm = true;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'ប្តូរពាក្យសម្ងាត់',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Current password
                      const Text(
                        'ពាក្យសម្ងាត់បច្ចុប្បន្ន',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: currentPassCtrl,
                        obscureText: isObscureCurrent,
                        decoration: InputDecoration(
                          hintText: 'បញ្ចូលពាក្យសម្ងាត់ចាស់',
                          hintStyle: const TextStyle(fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscureCurrent
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () => setSheetState(
                              () => isObscureCurrent = !isObscureCurrent,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'សូមបញ្ចូលពាក្យសម្ងាត់ចាស់'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // New password
                      const Text(
                        'ពាក្យសម្ងាត់ថ្មី',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: newPassCtrl,
                        obscureText: isObscureNew,
                        decoration: InputDecoration(
                          hintText: 'យ៉ាងហោចណាស់ ៦ តួអក្សរ',
                          hintStyle: const TextStyle(fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscureNew
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () => setSheetState(
                              () => isObscureNew = !isObscureNew,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'សូមបញ្ចូលពាក្យសម្ងាត់ថ្មី';
                          }
                          if (v.length < 6) {
                            return 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងតិច ៦ ខ្ទង់';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Confirm new password
                      const Text(
                        'បញ្ជាក់ពាក្យសម្ងាត់ថ្មី',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: confirmPassCtrl,
                        obscureText: isObscureConfirm,
                        decoration: InputDecoration(
                          hintText: 'បញ្ចូលពាក្យសម្ងាត់ថ្មីម្តងទៀត',
                          hintStyle: const TextStyle(fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () => setSheetState(
                              () => isObscureConfirm = !isObscureConfirm,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'សូមបញ្ជាក់ពាក្យសម្ងាត់ថ្មី';
                          }
                          if (v != newPassCtrl.text) {
                            return 'ពាក្យសម្ងាត់មិនផ្ទៀងផ្ទាត់គ្នាទេ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.primary,
                            disabledForegroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setSheetState(() => isSubmitting = true);

                                  try {
                                    final res = await ApiClient.instance.put(
                                      '/change-password',
                                      data: {
                                        'current_password':
                                            currentPassCtrl.text,
                                        'new_password': newPassCtrl.text,
                                        'new_password_confirmation':
                                            confirmPassCtrl.text,
                                      },
                                    );

                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                    }
                                    AppAlert.success(
                                      'ជោគជ័យ',
                                      res.data?['message'] ??
                                          'ពាក្យសម្ងាត់ត្រូវបានផ្លាស់ប្តូរដោយជោគជ័យ',
                                    );
                                  } on DioException catch (e) {
                                    final msg =
                                        e.response?.data?['message'] ??
                                        e.message ??
                                        'ការប្តូរពាក្យសម្ងាត់បានបរាជ័យ';
                                    AppAlert.error('កំហុស', msg);
                                  } finally {
                                    setSheetState(() => isSubmitting = false);
                                  }
                                },
                          child: ModernButtonContent(
                            isLoading: isSubmitting,
                            text: 'រក្សាទុកពាក្យសម្ងាត់ថ្មី',
                            loadingText: 'កំពុងរក្សាទុក',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final isOwner = user?.isOwner ?? false;

    return Scaffold(
      backgroundColor: AppColors.bgsf,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'ឯកជនភាព និងសុវត្ថិភាព',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Get.back(result: true),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Identity & Account Info Card
            _buildSectionHeader('ព័ត៌មានគណនី (User Information)'),
            const SizedBox(height: 8),
            _buildCard([
              _buildInfoTile(
                icon: Icons.person_outline_rounded,
                label: 'ឈ្មោះពេញ',
                value: user?.name.isNotEmpty == true
                    ? user!.name
                    : 'មិនទាន់កំណត់',
              ),
              _buildDivider(),
              _buildInfoTile(
                icon: Icons.email_outlined,
                label: 'អ៊ីមែល',
                value: user?.email.isNotEmpty == true
                    ? user!.email
                    : 'មិនទាន់កំណត់',
              ),
              _buildDivider(),
              _buildInfoTile(
                icon: Icons.phone_outlined,
                label: 'លេខទូរស័ព្ទ',
                value: user?.phone?.isNotEmpty == true
                    ? user!.phone!
                    : 'មិនទាន់កំណត់',
              ),
              _buildDivider(),
              _buildInfoTile(
                icon: Icons.send_rounded,
                label: 'តេឡេក្រាម (Telegram)',
                value: user?.telegram?.isNotEmpty == true
                    ? user!.telegram!
                    : 'មិនទាន់កំណត់',
              ),
              _buildDivider(),
              _buildInfoTile(
                icon: Icons.location_on_outlined,
                label: 'ទីតាំងរស់នៅ',
                value: user?.locationTag?.isNotEmpty == true
                    ? user!.locationTag!
                    : 'មិនទាន់កំណត់',
              ),
              _buildDivider(),
              _buildInfoTile(
                icon: Icons.badge_outlined,
                label: 'តួនាទីគណនី',
                customValue:
                    user?.role?.name != null && user!.role!.name.isNotEmpty
                    ? RoleBadge(role: user.role!.name)
                    : const Text(
                        'Customer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
              ),
            ]),

            const SizedBox(height: 20),

            // 2. Owner Payment & Business Info Card (if Owner or Bakong details exist)
            if (isOwner ||
                (user?.bakongAccountId != null &&
                    user!.bakongAccountId!.isNotEmpty)) ...[
              _buildSectionHeader('ព័ត៌មានម្ចាស់បន្ទប់ (Owner & Payment)'),
              const SizedBox(height: 8),
              _buildCard([
                _buildInfoTile(
                  icon: Icons.qr_code_2_rounded,
                  label: 'គណនីបាគង KHQR',
                  value: user?.bakongAccountId?.isNotEmpty == true
                      ? user!.bakongAccountId!
                      : 'មិនទាន់កំណត់',
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.storefront_outlined,
                  label: 'ឈ្មោះអាជីវករ (Merchant Name)',
                  value: user?.bakongMerchantName?.isNotEmpty == true
                      ? user!.bakongMerchantName!
                      : 'មិនទាន់កំណត់',
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.verified_user_outlined,
                  label: 'ស្ថានភាពផ្ទៀងផ្ទាត់',
                  value: user?.isVerified == true
                      ? 'បានផ្ទៀងផ្ទាត់ (Verified)'
                      : 'ធម្មតា (Standard)',
                ),
              ]),
              const SizedBox(height: 20),
            ],

            // 3. Security Actions Card (Password & Session)
            _buildSectionHeader('សុវត្ថិភាពគណនី (Account Security)'),
            const SizedBox(height: 8),
            _buildCard([
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
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: Color(0xFF1D4ED8),
                    size: 20,
                  ),
                ),
                title: const Text(
                  'ប្តូរពាក្យសម្ងាត់',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                subtitle: const Text(
                  'ការពារគណនីរបស់អ្នកដោយផ្លាស់ប្តូរពាក្យសម្ងាត់ថ្មី',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
                onTap: _showChangePasswordDialog,
              ),
              _buildDivider(),
              _buildInfoTile(
                icon: Icons.security_rounded,
                label: 'ប្រព័ន្ធផ្ទៀងផ្ទាត់',
                value: 'JWT Authentication (Protected)',
              ),
            ]),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 52,
      endIndent: 16,
      color: Color(0xFFF1F5F9),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    Color iconColor = const Color(0xFF1D4ED8),
    required String label,
    String? value,
    Widget? customValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                if (customValue != null)
                  customValue
                else
                  Text(
                    value ?? 'មិនទាន់កំណត់',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
