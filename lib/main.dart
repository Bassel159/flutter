import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:internseek/auth/signup.dart';
import 'package:internseek/categories/add.dart';
import 'package:internseek/home.dart';
import 'package:internseek/editprofile.dart';
import 'package:internseek/profile.dart';
import 'package:internseek/settings.dart';
import 'package:internseek/showcv.dart';
import 'package:internseek/uploadcv.dart';
import 'auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('==================User is currently signed out!');
      } else {
        print('=================User is signed in!');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.purple,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home:
          (FirebaseAuth.instance.currentUser != null &&
                  FirebaseAuth.instance.currentUser!.emailVerified)
              ? Home()
              : LogIn(),
      routes: {
        "signup": (context) => SignUp(),
        "login": (context) => LogIn(),
        "homepage": (context) => HomePage(),
        "addcategory": (context) => AddCategory(),
        "home": (context) => Home(),
        "settings":
            (context) => Settings(
              isDark: _themeMode == ThemeMode.dark,
              onToggleTheme: _toggleTheme,
            ),
        "profile": (context) => Profile(),
        "editprofile": (context) => Editprofile(),
        "uploadcv": (context) => UploadCVPage(),
        "showcv": (context) => ViewCVPage(),
      },
    );
  }
}
