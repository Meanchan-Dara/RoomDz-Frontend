import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/view/own_room/my_rooms_screen.dart';
import 'package:roomdz_frontend/view/own_room/owner_dashboard_screen.dart';
import 'package:roomdz_frontend/view/own_room/owner_notification_screen.dart';
import 'package:roomdz_frontend/view/own_room/viewing_request_screen.dart';

// shared profile screen
import 'package:roomdz_frontend/view/user/profile_Screen.dart';

class ParentScreenOwn extends StatelessWidget {
  const ParentScreenOwn({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      tabs: [
        // dashboard
        PersistentTabConfig(
          screen: OwnerDashboardScreen(),
          item: ItemConfig(
            textStyle: GoogleFonts.battambang(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            icon: const Icon(Icons.dashboard),
            title: 'ផ្ទាំងគ្រប់គ្រង',
            inactiveIcon: const Icon(Icons.dashboard_outlined),
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: Colors.grey,
          ),
        ),

        // my rooms
        PersistentTabConfig(
          screen: MyRoomsScreen(),
          item: ItemConfig(
            textStyle: GoogleFonts.battambang(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            icon: const Icon(Icons.home),
            title: 'បន្ទប់របស់ខ្ញុំ',
            inactiveIcon: const Icon(Icons.home_outlined),
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: Colors.grey,
          ),
        ),

        // viewing requests
        PersistentTabConfig(
          screen: ViewingRequestScreen(),
          item: ItemConfig(
            textStyle: GoogleFonts.battambang(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            icon: const Icon(Icons.calendar_month),
            title: 'សំណើមើលបន្ទប់',
            inactiveIcon: const Icon(Icons.calendar_month_outlined),
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: Colors.grey,
          ),
        ),

        // notifications
        PersistentTabConfig(
          screen: OwnerNotificationScreen(),
          item: ItemConfig(
            textStyle: GoogleFonts.battambang(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            icon: const Icon(Icons.notifications),
            title: 'ការជូនដំណឹង',
            inactiveIcon: const Icon(Icons.notifications_outlined),
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: Colors.grey,
          ),
        ),

        // profile
        PersistentTabConfig(
          screen: ProfileScreen(),
          item: ItemConfig(
            textStyle: GoogleFonts.battambang(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            icon: const Icon(Icons.person),
            title: 'ប្រវត្តិរូប',
            inactiveIcon: const Icon(Icons.person_outlined),
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: Colors.grey,
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
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
      ),
    );
  }
}
