import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:infomat/Colors.dart';
import 'dart:ui_web' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infomat/App.dart';
import 'package:infomat/views/Login.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'package:infomat/widgets/Widgets.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseOptions firebaseOptions = await loadFirebaseConfig();

  await Firebase.initializeApp(options: firebaseOptions);

  runApp(const MainApp());
}

Future<FirebaseOptions> loadFirebaseConfig() async {
  // Fetch the configuration from a JSON file
  final response = await html.HttpRequest.getString('firebase_config.json');
  final Map<String, dynamic> config = json.decode(response);
  return FirebaseOptions(
    apiKey: config['apiKey'],
    authDomain: config['authDomain'],
    projectId: config['projectId'],
    storageBucket: config['storageBucket'],
    messagingSenderId: config['messagingSenderId'],
    appId: config['appId'],
    measurementId: config['measurementId'],
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
  bool _isConsentGiven = false;
  bool settings = false;

  initState() {
    super.initState();

  }

  Future<void> sendLoginEvent() async {
    await analytics.logEvent(
      name: 'login',
      parameters: {
        'method': 'email', // or 'google', 'facebook', etc., depending on your auth methods
      },
    );
  }

  Future<void> sendUniqueEvent(String id) async {
    await analytics.logEvent(
      name: 'login',
      parameters: {
        'id': id, 
      },
    );
  }


  final userAgent = html.window.navigator.userAgent.toLowerCase();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: AppColors.getColor('primary').light,
        colorScheme: const ColorScheme.light().copyWith(
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
          displayMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          displaySmall: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          
          titleLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          titleMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          titleSmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),


          headlineLarge: TextStyle(fontSize: 24, fontFamily: GoogleFonts.poppins(fontWeight: FontWeight.w700).fontFamily),
          headlineMedium: TextStyle(fontSize: 20, fontFamily: GoogleFonts.poppins(fontWeight: FontWeight.w700).fontFamily),
          headlineSmall: TextStyle(fontSize: 16, fontFamily: GoogleFonts.poppins(fontWeight: FontWeight.w700).fontFamily),

          labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          labelMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          labelSmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),

          bodyLarge: const TextStyle(fontSize: 16),
          bodyMedium: const TextStyle(fontSize: 14),
          bodySmall: const TextStyle(fontSize: 12),
          
        ),
      ), // Apply your custom theme
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
              
            if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator if the authentication state is still loading
            return const CircularProgressIndicator();
            } else {
              if (snapshot.hasData) {
                // User is logged in, navigate to the specified screen
                sendUniqueEvent(snapshot.data!.uid);
                sendLoginEvent();
                return const App();
              } else {
                // User is not logged in, navigate to Login
                return  const Login();
                }
              }
            }
        ),
      );
    }
}