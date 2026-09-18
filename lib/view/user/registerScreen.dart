import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/service/auth_service.dart';
import 'package:roomdz_frontend/view/user/signInScreen.dart';

class Registerscreen extends StatefulWidget {
  const Registerscreen({super.key});

  @override
  State<Registerscreen> createState() => _RegisterscreenState();
}

class _RegisterscreenState extends State<Registerscreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isObscure = true;
  bool _isAgreed = false;

  // backend section
  bool isloading = false;
  final AuthService authService = AuthService();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Room-Dz',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),

                // title
                const Text(
                  'បង្កើតគណនីរបស់អ្នក',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'ចូលរួមជាមួយ Dz-RoomFinder ដើម្បីស្វែងរក​​​បន្ទប់សម្រាប់ជួលដែលអ្នកពេញចិត្ត។',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputLabel('ឈ្មោះពេញ'),
                const SizedBox(height: 8),
                buildTextFromField(
                  text: 'សុភា.......',
                  preIcons: Icons.person_outlined,
                  ctrl: _fullNameController,
                ),
                const SizedBox(height: 12),

                //email
                _buildInputLabel('អ៊ីមែល'),
                const SizedBox(height: 8),
                buildTextFromField(
                  text: 'email@example.com',
                  preIcons: Icons.email_outlined,
                  ctrl: _emailController,
                ),
                const SizedBox(height: 12),

                //Phone Number
                _buildInputLabel('លេខទូរស័ព្ទ'),
                const SizedBox(height: 8),
                buildTextFromField(
                  text: '+855 12345678',
                  preIcons: Icons.phone_outlined,
                  ctrl: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                //Password
                _buildInputLabel('ពាក្យសម្ងាត់'),
                const SizedBox(height: 8),
                buildTextFromField(
                  text: '********',
                  preIcons: Icons.lock_outline,
                  ctrl: _passwordController,
                  keyboardType: TextInputType.text,
                  obscureText: _isObscure,
                  subIcons: _isObscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off,
                ),
                const SizedBox(height: 12),

                //confirm
                _buildInputLabel('បញ្ជាក់ពាក្យសម្ងាត់'),
                const SizedBox(height: 8),
                buildTextFromField(
                  text: '********',
                  preIcons: Icons.lock_outline,
                  ctrl: _confirmPasswordController,
                  keyboardType: TextInputType.text,
                  isPassword: true,
                  obscureText: _isObscure,
                  subIcons: _isObscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off,
                ),

                // check and terms
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //check box
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _isAgreed,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        onChanged: (value) {
                          setState(() {
                            _isAgreed = value ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // text trems
                    Expanded(
                      child: Wrap(
                        children: [
                          const Text(
                            'ខ្ញុំយល់ព្រមតាម ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'លក្ខខណ្ឌ និងកិច្ចព្រមព្រៀង',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Text(
                            ' និង ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'គោលការណ៍ឯកជនភាព',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                //ele make acc
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isloading
                        ? null
                        : () async {
                            if (_passwordController.text !=
                                _confirmPasswordController.text) {
                              Get.snackbar(
                                'Error',
                                'Passwords do not match',
                                snackPosition: SnackPosition.TOP,
                              );
                              return;
                            }

                            if (!_isAgreed) {
                              Get.snackbar(
                                'Error',
                                'Please agree to the terms',
                                snackPosition: SnackPosition.TOP,
                              );
                              return;
                            }

                            setState(() {
                              isloading = true;
                            });

                            try {
                              await authService.register(
                                name: _fullNameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                                phone: _phoneController.text.trim(),
                              );

                              Get.snackbar(
                                'Success',
                                'Register successful',
                                snackPosition: SnackPosition.TOP,
                              );
                              Get.off(() => const Signinscreen());
                            } on DioException catch (e) {
                              final message =
                                  e.response?.data?['message'] ?? e.message;
                              log('REGISTER ERROR: $message');
                              Get.snackbar(
                                'Register Failed',
                                message.toString(),
                                snackPosition: SnackPosition.TOP,
                              );
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                e.toString(),
                                snackPosition: SnackPosition.TOP,
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  isloading = false;
                                });
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'បង្កើតគណនី',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                //already have ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'មានគណនីរួចហើយ? ',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const Signinscreen());
                      },
                      child: const Text(
                        'ចូលប្រព័ន្ធ',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }

  // text field build
  Widget buildTextFromField({
    required String text,
    required IconData preIcons,
    required TextEditingController ctrl,
    IconData? subIcons,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool isPassword = false,
  }) {
    return TextFormField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      controller: ctrl,
      decoration: InputDecoration(
        hintText: text,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: Icon(preIcons, color: const Color(0xFF64748B)),
        suffixIcon: IconButton(
          icon: Icon(subIcons, color: const Color(0xFF64748B)),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 199, 219, 246),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}
