import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'លក្ខខណ្ឌនៃការប្រើប្រាស់',
          style: GoogleFonts.battambang(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            '១. ការទទួលយកលក្ខខណ្ឌ៖ ការប្រើប្រាស់កម្មវិធី RoomDz មានន័យថាអ្នកបានយល់ព្រមអនុវត្តតាមលក្ខខណ្ឌ និងគោលការណ៍នានារបស់យើងខ្ញុំ។\n\n'
            '២. គណនីអ្នកប្រើប្រាស់៖ អ្នកមានកាតព្វកិច្ចរក្សាការសម្ងាត់នៃលេខសម្ងាត់ និងព័ត៌មានផ្ទាល់ខ្លួនរបស់អ្នក។\n\n'
            '៣. ភាពត្រឹមត្រូវនៃព័ត៌មានបន្ទប់៖ ម្ចាស់បន្ទប់ត្រូវធានាថា រាល់ព័ត៌មាន និងរូបភាពបន្ទប់ដែលបានបង្ហោះ គឺពិតប្រាកដ និងត្រឹមត្រូវ។\n\n'
            '៤. ការទូទាត់ប្រាក់៖ រាល់ប្រតិបត្តិការទូទាត់ប្រាក់កក់ ឬថ្លៃជួលត្រូវធ្វើឡើងដោយផ្អែកលើការព្រមព្រៀងគ្នារវាងភាគីទាំងពីរ។\n\n'
            '៥. ការកែប្រែលក្ខខណ្ឌ៖ RoomDz រក្សាសិទ្ធិកែប្រែលក្ខខណ្ឌទាំងនេះគ្រប់ពេលវេលាដោយជូនដំណឹងជាមុន។',
            style: GoogleFonts.battambang(
              fontSize: 13,
              height: 1.6,
              color: const Color(0xFF334155),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'យល់ព្រម',
              style: GoogleFonts.battambang(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'គោលការណ៍ឯកជនភាព',
          style: GoogleFonts.battambang(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'យើងខ្ញុំប្តេជ្ញាការពារទិន្នន័យផ្ទាល់ខ្លួនរបស់អ្នក៖\n\n'
            '១. ការប្រមូលទិន្នន័យ៖ យើងប្រមូលតែព័ត៌មានចាំបាច់ដូចជា ឈ្មោះ អ៊ីមែល លេខទូរស័ព្ទ និងទីតាំង ដើម្បីជួយសម្រួលដល់ការស្វែងរក និងណាត់ជួបមើលបន្ទប់ប៉ុណ្ណោះ។\n\n'
            '២. ការការពារព័ត៌មាន៖ ទិន្នន័យទាំងអស់ត្រូវបានរក្សាទុកដោយសុវត្ថិភាពខ្ពស់ និងប្រើប្រាស់ Token JWT ក្នុងការផ្ទៀងផ្ទាត់។\n\n'
            '៣. មិនចែករំលែកជាមួយភាគីទីបី៖ យើងមិនលក់ ឬចែករំលែកទិន្នន័យផ្ទាល់ខ្លួនរបស់អ្នកទៅកាន់ភាគីទីបីដោយគ្មានការអនុញ្ញាតឡើយ។\n\n'
            '៤. សិទ្ធិរបស់អ្នក៖ អ្នកអាចស្នើសុំកែប្រែ ឬលុបគណនី និងទិន្នន័យរបស់អ្នកបានគ្រប់ពេលវេលា។',
            style: GoogleFonts.battambang(
              fontSize: 13,
              height: 1.6,
              color: const Color(0xFF334155),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'យល់ព្រម',
              style: GoogleFonts.battambang(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.neutral,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'អំពី RoomDz',
          style: GoogleFonts.battambang(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.neutral,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Logo & Title
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.home_work_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              'RoomDz',
              style: GoogleFonts.battambang(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral,
              ),
            ),
            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Version 1.0.0 (Build 100)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Description card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                'RoomDz គឺជាប្រព័ន្ធគ្រប់គ្រង និងស្វែងរកបន្ទប់ជួលទំនើបនៅក្នុងប្រទេសកម្ពុជា ដែលជួយតភ្ជាប់រវាងអ្នកស្វែងរកបន្ទប់ស្នាក់នៅ និងម្ចាស់បន្ទប់យ៉ាងងាយស្រួល រហ័ស និងមានទំនុកចិត្តខ្ពស់។',
                textAlign: TextAlign.center,
                style: GoogleFonts.battambang(
                  fontSize: 14,
                  height: 1.6,
                  color: const Color(0xFF334155),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Feature Highlights
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'លក្ខណៈពិសេសចម្បងៗ',
                style: GoogleFonts.battambang(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _buildFeatureTile(
              icon: Icons.map_rounded,
              title: 'ស្វែងរកតាមទីតាំង និងផែនទី',
              subtitle: 'ស្វែងរកបន្ទប់នៅជិតលោកអ្នកជាមួយផែនទីជាក់ស្តែង',
            ),
            const SizedBox(height: 8),
            _buildFeatureTile(
              icon: Icons.calendar_month_rounded,
              title: 'ណាត់ជួបមើលបន្ទប់ផ្ទាល់',
              subtitle: 'ស្នើសុំណាត់ជួបមើលបន្ទប់ជាមួយម្ចាស់បន្ទប់ដោយឥតគិតថ្លៃ',
            ),
            const SizedBox(height: 8),
            _buildFeatureTile(
              icon: Icons.smart_toy_rounded,
              title: 'AI ជំនួយការឆ្លាតវៃ 24/7',
              subtitle: 'សាកសួរ និងណែនាំបន្ទប់ដែលស័ក្តិសមជាមួយ AI Bot',
            ),
            const SizedBox(height: 8),
            _buildFeatureTile(
              icon: Icons.qr_code_scanner_rounded,
              title: 'ទូទាត់តាម Bakong KHQR',
              subtitle: 'គាំទ្រការទូទាត់ប្រាក់កក់ប្រកបដោយសុវត្ថិភាព និងលឿនរហ័ស',
            ),

            const SizedBox(height: 20),

            // Legal & Terms buttons
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'លក្ខខណ្ឌនៃការប្រើប្រាស់',
                      style: GoogleFonts.battambang(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                    onTap: () => _showTermsDialog(context),
                  ),
                  const Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 16,
                    color: Color(0xFFE2E8F0),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'គោលការណ៍ឯកជនភាព',
                      style: GoogleFonts.battambang(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                    onTap: () => _showPrivacyDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              '© 2026 RoomDz. រក្សាសិទ្ធិគ្រប់យ៉ាង។',
              style: GoogleFonts.battambang(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1D4ED8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1D4ED8), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.battambang(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.battambang(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
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
