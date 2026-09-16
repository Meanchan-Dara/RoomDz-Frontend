import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/model/user_model.dart';
import 'package:roomdz_frontend/service/auth_service.dart';
import 'package:roomdz_frontend/service/database/database_service.dart';
import 'package:roomdz_frontend/view/homeScreen.dart';
import 'package:roomdz_frontend/widget/parentScreen.dart';
import 'package:roomdz_frontend/view/registerScreen.dart';

class Signinscreen extends StatefulWidget {
  const Signinscreen({super.key});

  @override
  State<Signinscreen> createState() => _SigninscreenState();
}

class _SigninscreenState extends State<Signinscreen> {
  final TextEditingController emailCtrl = TextEditingController();

  final TextEditingController passCtrl = TextEditingController();

  bool _isObscure = false;
  //backend section
  final AuthService authService = AuthService();

  bool isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: double.maxFinite,
                height: 250,
              ),
              Text(
                "សូមស្វាគមន៍មកកាន់ Room-Dz",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'ស្វែងរកបន្ទប់ដែលអ្នកពេញចិត្ត',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),

              Align(
                alignment: AlignmentGeometry.topLeft,
                child: Text(
                  'អ៊ីមែល',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              SizedBox(height: 8),
              buildTextFromField(
                subIcons: null,
                preIcons: Icons.email_outlined,
                text: 'បញ្ចូលអ៊ីមែលរបស់អ្នក',
                ctrl: emailCtrl,
              ),
              SizedBox(height: 8),

              // for get pass
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ពាក្យសម្ងាត់',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'ភ្លេចពាក្យសម្ងាត់?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              //password
              buildTextFromField(
                obscureText: _isObscure,
                preIcons: Icons.lock,
                subIcons: _isObscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_outlined,
                text: 'បញ្ចូលពាក្យសម្ងាត់របស់អ្នក',
                ctrl: passCtrl,
              ),

              // login
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: .8,
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        try {
                          final user = await authService.login(
                            email: emailCtrl.text.trim(),
                            password: passCtrl.text,
                          );
                          // Persist user + role so the app can auto-route on next launch
                          await DatabaseService.instance.saveUser(user);
                          if (!mounted) return;
                          Get.off(
                            () => Parentscreen(),
                          ); // Get.off, not Get.to — don't stack login on the back stack
                        } on DioException catch (e) {
                          final msg =
                              e.response?.data?['message'] ?? 'Login failed';
                          Get.snackbar('Error', msg);
                        } finally {
                          if (mounted) setState(() => isLoading = false);
                        }
                      },
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        "ចូលប្រេីប្រាស់",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              SizedBox(height: 8),

              //more options
              Row(
                children: const [
                  Expanded(
                    child: Divider(thickness: 1.2, color: Color(0xFFE2E8F0)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Or',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(thickness: 1.2, color: Color(0xFFE2E8F0)),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Continue with Google
              Container(
                padding: EdgeInsets.all(8),
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  style: OutlinedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        height: 25,
                        'https://cdn-icons-png.magnific.com/512/720/720255.png',
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.broken_image,
                              size: 24,
                              color: Colors.red,
                            ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'បន្តជាមួយ Google',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // create account
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'មិនទាន់មានគណនី? ',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => Registerscreen());
                    },
                    child: const Text(
                      'បង្កើតគណនី',
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
    );
  }

  Widget buildTextFromField({
    required String text,
    required IconData preIcons,
    bool obscureText = false,
    IconData? subIcons,

    required TextEditingController ctrl,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: text,
        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: Icon(preIcons, color: Color(0xFF64748B)),
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
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color.fromARGB(255, 199, 219, 246)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}
