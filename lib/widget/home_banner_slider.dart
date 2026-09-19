import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';

class HomeBannerSlider extends StatefulWidget {
  final VoidCallback? onBannerTap;

  const HomeBannerSlider({super.key, this.onBannerTap});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _BannerItem {
  final String tag;
  final IconData tagIcon;
  final Color tagColor;
  final String title;
  final String subtitle;
  final String buttonText;
  final String imageUrl;
  final List<Color> gradient;

  const _BannerItem({
    required this.tag,
    required this.tagIcon,
    required this.tagColor,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imageUrl,
    required this.gradient,
  });
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<_BannerItem> _banners = const [
    _BannerItem(
      tag: 'ពេញនិយម',
      tagIcon: Icons.star_rounded,
      tagColor: Color(0xFFF59E0B),
      title: 'ស្វែងរកបន្ទប់ជួលក្នុងក្តីស្រមៃ',
      subtitle: 'បន្ទប់ស្អាត មានផាសុកភាព សុវត្ថិភាពខ្ពស់ និងតម្លៃសមរម្យ',
      buttonText: 'មើលបន្ទប់',
      imageUrl:
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=900&auto=format&fit=crop&q=80',
      gradient: [Color(0xCC0F172A), Color(0x991E293B), Color(0x33000000)],
    ),
    _BannerItem(
      tag: 'Bakong KHQR',
      tagIcon: Icons.qr_code_scanner_rounded,
      tagColor: Color(0xFFE11D48),
      title: 'កក់បន្ទប់ងាយស្រួលតាម KHQR',
      subtitle: 'ស្កេនបង់ប្រាក់កក់រហ័ស សុវត្ថិភាព តាមគ្រប់ App ធនាគារ',
      buttonText: 'កក់ភ្លាមៗ',
      imageUrl:
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=900&auto=format&fit=crop&q=80',
      gradient: [Color(0xCC1E1B4B), Color(0x99312E81), Color(0x33000000)],
    ),
    _BannerItem(
      tag: 'សេវាកម្មឥតគិតថ្លៃ',
      tagIcon: Icons.event_available_rounded,
      tagColor: Color(0xFF10B981),
      title: 'ណាត់ជួបមើលបន្ទប់ដោយផ្ទាល់',
      subtitle: 'ជ្រើសរើសថ្ងៃ និងម៉ោងដែលអ្នកទំនេរ ដើម្បីចុះមើលបន្ទប់ពិត',
      buttonText: 'ណាត់ជួប',
      imageUrl:
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=900&auto=format&fit=crop&q=80',
      gradient: [Color(0xCC064E3B), Color(0x99047857), Color(0x33000000)],
    ),
  ];

  static const int _initialPageMultiplier = 1000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _banners.length * _initialPageMultiplier,
    );
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Slider Container
        SizedBox(
          height: 165,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index % _banners.length);
            },
            itemBuilder: (context, index) {
              final banner = _banners[index % _banners.length];
              return _buildBannerCard(banner);
            },
          ),
        ),

        const SizedBox(height: 10),

        // Animated Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerCard(_BannerItem banner) {
    return GestureDetector(
      onTap: widget.onBannerTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            CachedNetworkImage(
              imageUrl: banner.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: const Color(0xFFE2E8F0)),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFF1E293B),
                child: const Icon(
                  Icons.apartment_rounded,
                  size: 40,
                  color: Colors.white38,
                ),
              ),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: banner.gradient,
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Tag Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(banner.tagIcon, size: 13, color: banner.tagColor),
                        const SizedBox(width: 4),
                        Text(
                          banner.tag,
                          style: GoogleFonts.battambang(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Title and Subtitle + Action Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              banner.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.battambang(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              banner.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.battambang(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Pill Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          banner.buttonText,
                          style: GoogleFonts.battambang(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
    );
  }
}
