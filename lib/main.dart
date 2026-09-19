import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/controller/favorite_controller.dart';
import 'package:roomdz_frontend/controller/profile_controller.dart';
import 'package:roomdz_frontend/service/api_client.dart';
import 'package:roomdz_frontend/service/database/database_service.dart';
import 'package:roomdz_frontend/view/user/signInScreen.dart';
import 'package:roomdz_frontend/widget/parentScreen.dart';
import 'package:roomdz_frontend/widget/parent_screen_own.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(FavoriteController());
  Get.put(ProfileController(), permanent: true);

  // Check both SQLite session and JWT token in secure storage
  final savedUser = await DatabaseService.instance.getSavedUser();
  final hasToken = await ApiClient.hasToken();

  final Widget initialHome = (savedUser != null && hasToken)
      ? _resolveHome(savedUser.role?.name)
      : const Signinscreen();

  runApp(MyApp(initialHome: initialHome));
}

Widget _resolveHome(String? roleName) {
  switch (DatabaseService.normalizeRole(roleName)) {
    case 'admin':
      return Container();
    case 'owner':
      return const ParentScreenOwn();
    case 'customer':
      return const Parentscreen();
    default:
      if (roleName == null) return const Signinscreen();
      return const Parentscreen();
  }
}

class MyApp extends StatelessWidget {
  final Widget initialHome;
  const MyApp({super.key, required this.initialHome});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: initialHome,
      theme: ThemeData(textTheme: GoogleFonts.battambangTextTheme()),
    );
  }
}
