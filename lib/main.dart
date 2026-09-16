import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/controller/favorite_controller.dart';
import 'package:roomdz_frontend/view/signInScreen.dart';
import 'package:roomdz_frontend/widget/parentScreen.dart';
import 'firebase_options.dart';

void main() async {
  Get.put(FavoriteController());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Signinscreen(),
      theme: ThemeData(textTheme: GoogleFonts.battambangTextTheme()),
    );
  }
}
