import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/view/signInScreen.dart';

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

  bool _isObscure = false;
  bool _isAgreed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 70,
                      fit: BoxFit.fitWidth,
                    ),
                    Text(
                      'Dz-RoomFinder',
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
                Text(
                  'បង្កើតគណនីរបស់អ្នក',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'ចូលរួមជាមួយ Dz-RoomFinder ដើម្បីស្វែងរក​​​បន្ទប់សម្រាប់ជួលដែលអ្នកពេញចិត្ត។',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16),
                _buildInputLabel('ឈ្មោះពេញ'),
                SizedBox(height: 8),
                buildTextFromField(
                  text: 'សុភា.......',
                  preIcons: Icons.person_outlined,
                  ctrl: _fullNameController,
                ),
                SizedBox(height: 12),

                //email
                _buildInputLabel('អ៊ីមែល'), SizedBox(height: 8),
                buildTextFromField(
                  text: 'email@example.com',
                  preIcons: Icons.email_outlined,
                  ctrl: _emailController,
                ),
                SizedBox(height: 12),

                //Phone Number
                _buildInputLabel('លេខទូរស័ព្ទ'), SizedBox(height: 8),
                buildTextFromField(
                  text: '+855 12345678',
                  preIcons: Icons.phone_outlined,
                  ctrl: _phoneController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),

                //Password
                _buildInputLabel('ពាក្យសម្ងាត់'), SizedBox(height: 8),
                buildTextFromField(
                  text: '********',
                  preIcons: Icons.lock_outline,
                  ctrl: _passwordController,
                  keyboardType: TextInputType.number,
                  obscureText: _isObscure,
                  subIcons: _isObscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off,
                ),
                SizedBox(height: 12),

                //comfirm
                _buildInputLabel('បញ្ជាក់ពាក្យសម្ងាត់'), SizedBox(height: 8),
                buildTextFromField(
                  text: '********',
                  preIcons: Icons.lock_outline,
                  ctrl: _confirmPasswordController,
                  keyboardType: TextInputType.number,
                  isPassword: true,
                  obscureText: _isObscure,
                  subIcons: _isObscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off,
                ),

                // check and terms
                SizedBox(height: 16),
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
                          Text(
                            'ខ្ញុំយល់ព្រមតាម ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'លក្ខខណ្ឌ និងកិច្ចព្រមព្រៀង',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Text(
                            ' និង ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
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
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
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
                SizedBox(height: 16),
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
                        Get.to(() => Signinscreen());
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
