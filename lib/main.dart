import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/controller/favorite_controller.dart';
import 'package:roomdz_frontend/service/database/database_service.dart';
import 'package:roomdz_frontend/view/signInScreen.dart';
import 'package:roomdz_frontend/widget/parentScreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(FavoriteController());

  //  SQLite for an existing session
  final savedUser = await DatabaseService.instance.getSavedUser();

  runApp(MyApp(initialHome: _resolveHome(savedUser?.role?.name)));
}

Widget _resolveHome(String? roleName) {
  switch (DatabaseService.normalizeRole(roleName)) {
    case 'admin':
      return Parentscreen();
    case 'owner':
      return Parentscreen();
    case 'customer':
    // user@gmail.com
    //12345678
    default:
      if (roleName == null) return Signinscreen();
      return Parentscreen();
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
