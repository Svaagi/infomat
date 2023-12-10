import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:infomat/Colors.dart';
import 'dart:ui_web' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infomat/App.dart';
import 'package:infomat/views/Login.dart';

void main() async {
  ui.bootstrapEngine();



  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDDQ-UETB03fLb52hdDToOWbhihWlYopMU",
      authDomain: "infomat-39565.firebaseapp.com",
      projectId: "infomat-39565",
      storageBucket: "infomat-39565.appspot.com",
      messagingSenderId: "499783588915",
      appId: "1:499783588915:web:bf87bfc63cb8ca258a5746",
      measurementId: "G-VJ1NGGB6G4"
    ),
  );

  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: AppColors.getColor('primary').light,
        colorScheme: ColorScheme.light().copyWith(
          primary: AppColors.getColor('primary').light,
          primaryContainer: AppColors.getColor('primary').light,
          onPrimaryContainer: AppColors.getColor('mono').white,
          onPrimary: AppColors.getColor('mono').white,
          background: AppColors.getColor('mono').white,
          onBackground: AppColors.getColor('mono').black,
          error: AppColors.getColor('red').main,
        ),

        fontFamily: GoogleFonts.inter().fontFamily,

        // Define the default font family.

        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontFamily: GoogleFonts.poppins(fontWeight: FontWeight.w700).fontFamily),
          displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          displaySmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          
          titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),


          headlineLarge: TextStyle(fontSize: 24, fontFamily: GoogleFonts.poppins(fontWeight: FontWeight.w700).fontFamily),
          headlineMedium: TextStyle(fontSize: 20, fontFamily: GoogleFonts.poppins(fontWeight: FontWeight.w700).fontFamily),
          headlineSmall: TextStyle(fontSize: 16, fontFamily: GoogleFonts.poppins(fontWeight: FontWeight.w700).fontFamily),

          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),

          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          bodySmall: TextStyle(fontSize: 12),
          
        ),
      ), // Apply your custom theme
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator if the authentication state is still loading
            return CircularProgressIndicator();
          } else {
            if (snapshot.hasData) {
              // User is logged in, navigate to the specified screen
              return App();
            } else {
              // User is not logged in, navigate to Login
              return Login();
            }
          }
        },
      ),
    );
  }
}