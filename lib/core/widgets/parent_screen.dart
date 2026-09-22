import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:roomdz_frontend/core/constants/app_colors.dart';
import 'package:roomdz_frontend/features/chatbot/ui/screens/chatbot_screen.dart';
import 'package:roomdz_frontend/features/rooms/ui/screens/favorite_screen.dart';
import 'package:roomdz_frontend/features/rooms/ui/screens/home_screen.dart';
import 'package:roomdz_frontend/features/rooms/ui/screens/map_screen.dart';
import 'package:roomdz_frontend/features/auth/ui/screens/profile_screen.dart';
import 'package:roomdz_frontend/features/rooms/ui/screens/search_screen.dart';

class Parentscreen extends StatelessWidget {
  const Parentscreen({super.key});

  void _openChatbot(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PersistentTabView(
            backgroundColor: Colors.transparent,
            navBarOverlap: const NavBarOverlap.full(),
            tabs: [
              PersistentTabConfig(
                screen: Homescreen(),
                item: ItemConfig(
                  textStyle: GoogleFonts.battambang(),
                  icon: const Icon(Icons.home),
                  title: 'ទំព័រដើម',
                  inactiveIcon: const Icon(Icons.home_outlined),
                ),
              ),
              PersistentTabConfig(
                screen: SearchScreen(),
                item: ItemConfig(
                  textStyle: GoogleFonts.battambang(),
                  icon: const Icon(Icons.search),
                  title: 'ស្វែងរក',
                  inactiveIcon: const Icon(Icons.search_outlined),
                  activeForegroundColor: AppColors.primary,
                ),
              ),
              PersistentTabConfig(
                screen: Mapscreen(),
                item: ItemConfig(
                  textStyle: GoogleFonts.battambang(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  icon: const Icon(
                    Icons.location_on,
                    size: 25,
                    color: Colors.white,
                  ),
                  title: 'ទីតាំង',
                  inactiveIcon: const Icon(
                    Icons.location_on_outlined,
                    size: 25,
                    color: Colors.white,
                  ),
                  activeForegroundColor: AppColors.primary,
                  inactiveForegroundColor: Colors.grey,
                ),
              ),
              PersistentTabConfig(
                screen: FavoriteScreen(),
                item: ItemConfig(
                  textStyle: GoogleFonts.battambang(),
                  icon: const Icon(Icons.favorite),
                  title: 'ចូលចិត្ត',
                  inactiveIcon: const Icon(Icons.favorite_outline_outlined),
                  activeForegroundColor: AppColors.primary,
                ),
              ),
              PersistentTabConfig(
                screen: ProfileScreen(),
                item: ItemConfig(
                  textStyle: GoogleFonts.battambang(),
                  icon: const Icon(Icons.person),
                  title: 'ប្រវត្តិរូប',
                  inactiveIcon: const Icon(Icons.person_outlined),
                  activeForegroundColor: AppColors.primary,
                ),
              ),
            ],
            navBarBuilder: (navBarConfig) => Style13BottomNavBar(
              navBarConfig: navBarConfig,
              navBarDecoration: NavBarDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
            ),
          ),
          // Floating AI Chatbot Icon above bottom navigation bar
          Positioned(
            right: 16,
            bottom: 96,
            child: Material(
              elevation: 0,
              shape: const CircleBorder(),
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openChatbot(context),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.22),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.smart_toy_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
