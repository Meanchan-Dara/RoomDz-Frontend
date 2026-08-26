import 'package:flutter/material.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';

class Signinscreen extends StatefulWidget {
  Signinscreen({super.key});

  @override
  State<Signinscreen> createState() => _SigninscreenState();
}

class _SigninscreenState extends State<Signinscreen> {
  final TextEditingController emailCtrl = TextEditingController();

  final TextEditingController passCtrl = TextEditingController();

  bool _isObscure = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                "assets/images/image.png",
                width: double.maxFinite,
                height: 200,
              ),
              Text(
                "សូមស្វាគមន៍មកកាន់ Dz-Room",
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
