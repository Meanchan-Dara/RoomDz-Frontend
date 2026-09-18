import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/model/view_quest_model.dart';
import 'package:roomdz_frontend/service/viewing_request_service.dart';
import 'package:roomdz_frontend/view/user/profile_contents/my_requests_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MyRentingScreen extends StatefulWidget {
  const MyRentingScreen({super.key});

  @override
  State<MyRentingScreen> createState() => _MyRentingScreenState();
}

class _MyRentingScreenState extends State<MyRentingScreen> {
  final ViewingRequestService _requestService = ViewingRequestService();
  List<ViewingRequestModel> _confirmedRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRentingRooms();
  }

  Future<void> _fetchRentingRooms() async {
    setState(() => _isLoading = true);
    try {
      final all = await _requestService.getMyViewingRequests();
      if (mounted) {
        setState(() {
          _confirmedRequests = all
              .where((r) => r.status.toLowerCase() == 'confirmed')
              .toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _launchCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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
          'បន្ទប់កំពុងជួល',
          style: GoogleFonts.battambang(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.neutral,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchRentingRooms,
              child: _confirmedRequests.isNotEmpty
                  ? _buildBackendRentedList()
                  : _buildMockRentingCard(),
            ),
    );
  }

  // If backend has confirmed viewing requests
  Widget _buildBackendRentedList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _confirmedRequests.length,
      itemBuilder: (context, index) {
        final req = _confirmedRequests[index];
        final room = req.room;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room image & confirmed status
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: (room?.image != null && room!.image!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: room.image ?? '',
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                _buildFallbackBanner(),
                          )
                        : _buildFallbackBanner(),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'កំពុងស្នាក់នៅ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room?.name ?? 'បន្ទប់ជួល',
                      style: GoogleFonts.battambang(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            room?.address ?? 'រាជធានីភ្នំពេញ',
                            style: GoogleFonts.battambang(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ថ្លៃជួលប្រចាំខែ',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${room?.price ?? 0}/ខែ',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        if (req.phone != null && req.phone!.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () => _launchCall(req.phone!),
                            icon: const Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'ទាក់ទង',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Realistic mock data if no confirmed rooms yet in backend
  Widget _buildMockRentingCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Demo Notice Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'បច្ចុប្បន្នអ្នកមិនទាន់មានបន្ទប់ជួលជាក់ស្តែងទេ។ ខាងក្រោមនេះជាទិន្នន័យគំរូ (Mock Data) បង្ហាញពីទម្រង់បន្ទប់កំពុងជួល៖',
                    style: GoogleFonts.battambang(
                      fontSize: 12,
                      color: const Color(0xFF1E40AF),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Active Rental Card (Mock Demo)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with Tag
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=800&q=80',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackBanner(),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.verified, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'កុងត្រាសកម្ម',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Studio Deluxe #302',
                              style: GoogleFonts.battambang(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const Text(
                            '\$180/ខែ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'ផ្លូវ 315, សង្កាត់បឹងកក់១, ខណ្ឌទួលគោក, ភ្នំពេញ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 14),

                      // Contract & Rent Details
                      _buildInfoRow(
                        Icons.calendar_today_rounded,
                        'កាលបរិច្ឆេទចាប់ផ្តើម',
                        '01-មករា-2026',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.event_busy_rounded,
                        'កាលបរិច្ឆេទផុតកំណត់',
                        '31-ធ្នូ-2026 (សល់ 10 ខែ)',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.payment_rounded,
                        'ថ្ងៃត្រូវបង់ថ្លៃឈ្នួល',
                        'ថ្ងៃទី 05 រៀងរាល់ខែ',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.person_outline_rounded,
                        'ម្ចាស់បន្ទប់',
                        'លោក ចាន់ តារា (012 888 999)',
                      ),

                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _launchCall('012888999'),
                              icon: const Icon(
                                Icons.phone,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              label: Text(
                                'ទាក់ទងម្ចាស់',
                                style: GoogleFonts.battambang(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.snackbar(
                                  'ទូទាត់ប្រាក់',
                                  'មុខងារបង់ប្រាក់តាម Bakong KHQR សម្រាប់ខែនេះបានរួចរាល់',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: const Color(0xFF10B981),
                                  colorText: Colors.white,
                                );
                              },
                              icon: const Icon(
                                Icons.qr_code_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: Text(
                                'បង់ថ្លៃឈ្នួល',
                                style: GoogleFonts.battambang(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Shortcut to requests
          Center(
            child: TextButton.icon(
              onPressed: () => Get.to(() => const MyRequestsScreen()),
              icon: const Icon(
                Icons.history_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                'មើលប្រវត្តិសំណើណាត់ជួបទាំងអស់',
                style: GoogleFonts.battambang(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.battambang(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.battambang(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      height: 160,
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: Icon(
          Icons.apartment_rounded,
          size: 48,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
