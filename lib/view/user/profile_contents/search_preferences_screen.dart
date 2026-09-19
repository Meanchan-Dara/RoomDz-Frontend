import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/widget/app_alert.dart';
import 'package:roomdz_frontend/widget/modern_button_loader.dart';

class SearchPreferencesScreen extends StatefulWidget {
  const SearchPreferencesScreen({super.key});

  @override
  State<SearchPreferencesScreen> createState() =>
      _SearchPreferencesScreenState();
}

class _SearchPreferencesScreenState extends State<SearchPreferencesScreen> {
  RangeValues _priceRange = const RangeValues(50, 400);

  final List<String> _roomTypes = [
    'បន្ទប់គេងទោល',
    'អាផាតមិន',
    'ខុនដូ',
    'ផ្ទះជួល',
    'វីឡា',
  ];
  final Set<String> _selectedTypes = {'បន្ទប់គេងទោល', 'អាផាតមិន'};

  final List<String> _districts = [
    'ទួលគោក',
    'បឹងកេងកង',
    'ចំការមន',
    'សែនសុខ',
    'ដូនពេញ',
    '៧មករា',
    'មានជ័យ',
    'ច្បារអំពៅ',
  ];
  final Set<String> _selectedDistricts = {'ទួលគោក', 'បឹងកេងកង'};

  final List<Map<String, dynamic>> _amenities = [
    {'name': 'ម៉ាស៊ីនត្រជាក់', 'icon': Icons.ac_unit_rounded},
    {'name': 'វ៉ាយហ្វាយឥតគិតថ្លៃ', 'icon': Icons.wifi_rounded},
    {'name': 'ចំណតយានយន្ត', 'icon': Icons.local_parking_rounded},
    {'name': 'សន្តិសុខ 24/7', 'icon': Icons.shield_outlined},
    {'name': 'អាងហែលទឹក', 'icon': Icons.pool_rounded},
    {'name': 'កន្លែងហាត់ប្រាណ', 'icon': Icons.fitness_center_rounded},
    {'name': 'ផ្ទះបាយ', 'icon': Icons.kitchen_rounded},
    {'name': 'ជណ្តើរយន្ត', 'icon': Icons.elevator_rounded},
  ];
  final Set<String> _selectedAmenities = {
    'ម៉ាស៊ីនត្រជាក់',
    'វ៉ាយហ្វាយឥតគិតថ្លៃ',
  };

  bool _notifyNewMatches = true;
  bool _isLoading = false;

  Future<void> _savePreferences() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      Get.back();
      AppAlert.success('ជោគជ័យ', 'ចំណូលចិត្តស្វែងរករបស់អ្នកត្រូវបានរក្សាទុក');
    }
  }

  void _resetDefaults() {
    setState(() {
      _priceRange = const RangeValues(50, 400);
      _selectedTypes.clear();
      _selectedTypes.addAll(['បន្ទប់គេងទោល', 'អាផាតមិន']);
      _selectedDistricts.clear();
      _selectedDistricts.addAll(['ទួលគោក', 'បឹងកេងកង']);
      _selectedAmenities.clear();
      _selectedAmenities.addAll(['ម៉ាស៊ីនត្រជាក់', 'វ៉ាយហ្វាយឥតគិតថ្លៃ']);
      _notifyNewMatches = true;
    });
    AppAlert.info('កំណត់ឡើងវិញ', 'បានកំណត់ចំណូលចិត្តស្វែងរកទៅទម្រង់ដើម');
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
          'ការកំណត់ស្វែងរក',
          style: GoogleFonts.battambang(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.neutral,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _resetDefaults,
            child: Text(
              'ទម្រង់ដើម',
              style: GoogleFonts.battambang(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Range Card
            _buildSectionCard(
              title: 'កម្រិតតម្លៃប្រចាំខែ (\$)',
              icon: Icons.attach_money_rounded,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_priceRange.start.round()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'ដល់ \$${_priceRange.end.round()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 30,
                    max: 1000,
                    divisions: 97,
                    activeColor: AppColors.primary,
                    inactiveColor: const Color(0xFFE2E8F0),
                    onChanged: (values) {
                      setState(() => _priceRange = values);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '\$30/ខែ',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      Text(
                        '\$1,000+/ខែ',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Room Types
            _buildSectionCard(
              title: 'ប្រភេទបន្ទប់ដែលអ្នកចាប់អារម្មណ៍',
              icon: Icons.meeting_room_rounded,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _roomTypes.map((type) {
                  final isSelected = _selectedTypes.contains(type);
                  return FilterChip(
                    label: Text(type),
                    labelStyle: GoogleFonts.battambang(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF334155),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: const Color(0xFFF1F5F9),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTypes.add(type);
                        } else {
                          _selectedTypes.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Preferred Locations
            _buildSectionCard(
              title: 'តំបន់ ឬខណ្ឌដែលពេញចិត្ត',
              icon: Icons.location_city_rounded,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _districts.map((district) {
                  final isSelected = _selectedDistricts.contains(district);
                  return FilterChip(
                    label: Text(district),
                    labelStyle: GoogleFonts.battambang(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF334155),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: const Color(0xFFF1F5F9),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDistricts.add(district);
                        } else {
                          _selectedDistricts.remove(district);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Required Amenities
            _buildSectionCard(
              title: 'សម្ភារៈ និងសេវាកម្មចាំបាច់',
              icon: Icons.star_outline_rounded,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _amenities.map((item) {
                  final name = item['name'] as String;
                  final icon = item['icon'] as IconData;
                  final isSelected = _selectedAmenities.contains(name);
                  return FilterChip(
                    avatar: Icon(
                      icon,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    label: Text(name),
                    labelStyle: GoogleFonts.battambang(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF334155),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: const Color(0xFFF1F5F9),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAmenities.add(name);
                        } else {
                          _selectedAmenities.remove(name);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Auto-notify toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeTrackColor: AppColors.primary,
                title: Text(
                  'ជូនដំណឹងបន្ទប់ថ្មីដែលត្រូវនឹងចំណូលចិត្ត',
                  style: GoogleFonts.battambang(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                subtitle: Text(
                  'ទទួលបាន Notification ភ្លាមៗពេលមានបន្ទប់ថ្មីត្រូវបានបង្ហោះ',
                  style: GoogleFonts.battambang(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                value: _notifyNewMatches,
                onChanged: (val) => setState(() => _notifyNewMatches = val),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary,
                  disabledForegroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: ModernButtonContent(
                  isLoading: _isLoading,
                  text: 'រក្សាទុកការកំណត់',
                  loadingText: 'កំពុងរក្សាទុក',
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF1D4ED8)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.battambang(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
