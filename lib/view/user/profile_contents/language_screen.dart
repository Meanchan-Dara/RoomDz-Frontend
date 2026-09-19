import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/widget/app_alert.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'km'; // 'km' for Khmer, 'en' for English

  final List<Map<String, dynamic>> _languages = [
    {
      'code': 'km',
      'name': 'ភាសាខ្មែរ',
      'subname': 'Khmer (Cambodia)',
      'flag': '🇰🇭',
    },
    {
      'code': 'en',
      'name': 'English',
      'subname': 'English (United States)',
      'flag': '🇺🇸',
    },
  ];

  void _changeLanguage(String code) {
    setState(() {
      _selectedLanguage = code;
    });

    final langName = code == 'km' ? 'ភាសាខ្មែរ' : 'English';
    AppAlert.success('ជោគជ័យ', 'បានប្តូរភាសាទៅជា $langName');
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
          'ជ្រើសរើសភាសា',
          style: GoogleFonts.battambang(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.neutral,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ជ្រើសរើសភាសាដែលអ្នកពេញចិត្តប្រើប្រាស់ក្នុងកម្មវិធី',
              style: GoogleFonts.battambang(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _languages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final lang = entry.value;
                  final isSelected = _selectedLanguage == lang['code'];
                  final isLast = index == _languages.length - 1;

                  return Column(
                    children: [
                      InkWell(
                        onTap: () => _changeLanguage(lang['code']),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Text(
                                lang['flag'],
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang['name'],
                                      style: GoogleFonts.battambang(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.primary
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      lang['subname'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : const Color(0xFFCBD5E1),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast)
                        const Divider(
                          height: 1,
                          indent: 60,
                          endIndent: 16,
                          color: Color(0xFFE2E8F0),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
