import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/view/chatbotScreen.dart';
import 'package:roomdz_frontend/widget/modern_button_loader.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _feedbackCtrl = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'តើខ្ញុំអាចកក់សំណើណាត់ជួបមើលបន្ទប់ដោយរបៀបណា?',
      'answer':
          'ដើម្បីកក់សំណើណាត់ជួបមើលបន្ទប់ សូមចូលទៅកាន់ទំព័រព័ត៌មានលម្អិតនៃបន្ទប់ដែលអ្នកចាប់អារម្មណ៍ រួចចុចប៊ូតុង "ស្នើសុំមើលបន្ទប់"។ បន្ទាប់មកជ្រើសរើសកាលបរិច្ឆេទ ពេលវេលា និងបញ្ចូលព័ត៌មានទំនាក់ទំនងរបស់អ្នក រួចចុចបញ្ជូនសំណើ។ ម្ចាស់បន្ទប់នឹងពិនិត្យ និងឆ្លើយតបមកអ្នកវិញ។',
    },
    {
      'question': 'តើការស្នើសុំណាត់ជួបមើលបន្ទប់ត្រូវបង់ប្រាក់ដែរឬទេ?',
      'answer':
          'ការស្នើសុំណាត់ជួបមើលបន្ទប់តាមរយៈ RoomDz គឺឥតគិតថ្លៃ ១០០%។ អ្នកមិនចាំបាច់បង់ប្រាក់កក់ ឬកម្រៃសេវាណាមួយឡើយ ក្នុងការណាត់ជួបទៅមើលបន្ទប់ជាក់ស្តែង។',
    },
    {
      'question': 'តើខ្ញុំអាចទាក់ទងទៅកាន់ម្ចាស់បន្ទប់ដោយផ្ទាល់បានដោយរបៀបណា?',
      'answer':
          'នៅលើទំព័រព័ត៌មានលម្អិតបន្ទប់ មានប៊ូតុងទូរស័ព្ទ (Call) និង Telegram របស់ម្ចាស់បន្ទប់។ អ្នកអាចចុចដើម្បីហៅចេញ ឬផ្ញើសារសាកសួរព័ត៌មានបន្ថែមបានភ្លាមៗ។',
    },
    {
      'question': 'តើប្រព័ន្ធគាំទ្រការទូទាត់ប្រាក់តាមមធ្យោបាយណាខ្លះ?',
      'answer':
          'RoomDz គាំទ្រការទូទាត់ប្រាក់កក់ ឬថ្លៃជួលប្រចាំខែតាមរយៈស្តង់ដារ Bakong KHQR (ABA, ACLEDA, Canadia, Wing និងធនាគារនានាក្នុងប្រទេសកម្ពុជា) ប្រកបដោយសុវត្ថិភាព និងលឿនរហ័ស។',
    },
    {
      'question': 'តើខ្ញុំអាចលុប ឬបដិសេធសំណើណាត់ជួបវិញបានទេ?',
      'answer':
          'បាន! អ្នកគ្រាន់តែចូលទៅកាន់ Profile > សំណើរបស់ខ្ញុំ រួចស្វែងរកសំណើដែលអ្នកចង់លុប ហើយចុចប៊ូតុង "បោះបង់សំណើ"។',
    },
  ];

  Future<void> _launchUrlHelper(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'មិនអាចបើកបាន',
          'មិនអាចបើកតំណភ្ជាប់នេះបានទេ: $urlString',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
      }
    } catch (_) {
      Get.snackbar(
        'បរាជ័យ',
        'មានបញ្ហាក្នុងការបើកតំណភ្ជាប់',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  void _openChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        child: const ChatbotScreen(),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    final text = _feedbackCtrl.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'សូមបញ្ចូលព័ត៌មាន',
        'សូមសរសេរមតិកែលម្អ ឬបញ្ហាដែលអ្នកបានជួបប្រទះជាមុនសិន',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _feedbackCtrl.clear();
      });
      Get.snackbar(
        'សូមអរគុណ!',
        'មតិកែលម្អរបស់អ្នកត្រូវបានផ្ញើជូនក្រុមការងារដោយជោគជ័យ',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
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
          'ជំនួយ និងការគាំទ្រ',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'តើអ្នកត្រូវការជំនួយអ្វីខ្លះ?',
                          style: GoogleFonts.battambang(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ក្រុមការងារ RoomDz ត្រៀមជួយសម្រួលដល់លោកអ្នកជានិច្ច',
                          style: GoogleFonts.battambang(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick Contact Grid
            Text(
              'ទំនាក់ទំនងមកកាន់យើងខ្ញុំ',
              style: GoogleFonts.battambang(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.send_rounded,
                    title: 'Telegram',
                    subtitle: '@roomdz_support',
                    color: const Color(0xFF0284C7),
                    onTap: () =>
                        _launchUrlHelper('https://t.me/roomdz_support'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.phone_in_talk_rounded,
                    title: 'Hotline',
                    subtitle: '+855 12 345 678',
                    color: const Color(0xFF10B981),
                    onTap: () => _launchUrlHelper('tel:+85512345678'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.mail_outline_rounded,
                    title: 'Email',
                    subtitle: 'support@roomdz.com',
                    color: const Color(0xFFF59E0B),
                    onTap: () => _launchUrlHelper('mailto:support@roomdz.com'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.smart_toy_rounded,
                    title: 'AI Bot',
                    subtitle: 'ឆ្លើយតប 24/7',
                    color: const Color(0xFF8B5CF6),
                    onTap: _openChatbot,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // FAQ Section
            Text(
              'សំណួរដែលសួរញឹកញាប់ (FAQ)',
              style: GoogleFonts.battambang(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: _faqs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == _faqs.length - 1;

                  return Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: Text(
                            item['question']!,
                            style: GoogleFonts.battambang(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          childrenPadding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 14,
                          ),
                          children: [
                            Text(
                              item['answer']!,
                              style: GoogleFonts.battambang(
                                fontSize: 13,
                                color: const Color(0xFF475569),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        if (!isLast)
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Send Feedback / Report Issue
            Text(
              'ផ្ញើមតិកែលម្អ ឬរាយការណ៍បញ្ហា',
              style: GoogleFonts.battambang(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _feedbackCtrl,
                    maxLines: 4,
                    style: GoogleFonts.battambang(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'រៀបរាប់ពីបញ្ហា ឬគំនិតកែលម្អរបស់អ្នកនៅទីនេះ...',
                      hintStyle: GoogleFonts.battambang(
                        fontSize: 13,
                        color: const Color(0xFF94A3B8),
                      ),
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
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary,
                        disabledForegroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: ModernButtonContent(
                        isLoading: _isSubmitting,
                        text: 'ផ្ញើមតិកែលម្អ',
                        loadingText: 'កំពុងផ្ញើ',
                        icon: Icons.send_rounded,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
