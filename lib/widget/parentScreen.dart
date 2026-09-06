import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/view/homeScreen.dart';
import 'package:roomdz_frontend/view/mapScreen.dart';
import 'package:roomdz_frontend/view/profile_Screen.dart';

class Parentscreen extends StatelessWidget {
  const Parentscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      tabs: [
        PersistentTabConfig(
          screen: Homescreen(),
          item: ItemConfig(
            textStyle: GoogleFonts.battambang(),
            icon: Icon(Icons.home),
            title: 'ទំព័រដើម',
            inactiveIcon: Icon(Icons.home_outlined),
            // activeForegroundColor: AppColors.primary,
            // inactiveForegroundColor: AppColors.primary,
            // inactiveBackgroundColor: Colors.white,
          ),
        ),
        PersistentTabConfig(
          screen: Homescreen(),
          item: ItemConfig(
            textStyle: GoogleFonts.battambang(),
            icon: Icon(Icons.search),
            title: 'ស្វែងរក',
            inactiveIcon: Icon(Icons.search_outlined),
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

            icon: Icon(Icons.location_on, size: 25, color: Colors.white),
            title: 'ទីតាំង',
            inactiveIcon: Icon(Icons.location_on_outlined, size: 25),
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: Colors.white,
            // inactiveBackgroundColor: Colors.grey,
          ),
        ),
        PersistentTabConfig(
          screen: Homescreen(),
          item: ItemConfig(
            textStyle: GoogleFonts.battambang(),

            icon: Icon(Icons.favorite),
            title: 'ចូលចិត្ត',
            inactiveIcon: Icon(Icons.favorite_outlined),
            activeForegroundColor: AppColors.primary,
          ),
        ),
        PersistentTabConfig(
          screen: ProfileScreen(),
          item: ItemConfig(
            textStyle: GoogleFonts.battambang(),
            icon: Icon(Icons.person),
            title: 'ប្រវត្តិរូប',
            inactiveIcon: Icon(Icons.person_outlined),
            activeForegroundColor: AppColors.primary,
          ),
        ),
      ],
      navBarBuilder: (navBarConfig) => Style13BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
      ),
    );
  }
}
