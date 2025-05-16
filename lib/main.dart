import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:internseek/ApplicationsPage.dart';
import 'package:internseek/auth/signup.dart';
import 'package:internseek/categories/add.dart';
import 'package:internseek/companyProfile/adminHome.dart';
import 'package:internseek/companyProfile/companyHome.dart';
import 'package:internseek/companyProfile/companyProfile.dart';
import 'package:internseek/home.dart';
import 'package:internseek/studentProfile/enterInfo.dart';
import 'package:internseek/studentProfile/studentEditProfile.dart';
import 'package:internseek/studentProfile/studentProfile.dart';
import 'package:internseek/settings.dart';
import 'package:internseek/studentProfile/viewCV.dart';
import 'package:internseek/studentProfile/uploadCV.dart';
import 'auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'companyProfile/companySettings.dart';
import 'companyProfile/editCProfile.dart';
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
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null && user.emailVerified) {
              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return LogIn(); // fallback
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final userType = data['userType'];

                  if (userType == 'Company') {
                    return CompanyHome(); // replace with your actual widget
                  } else if (userType == 'Admin') {
                    return adminHome(); // replace with your actual widget
                  } else {
                    return Home();
                  }
                },
              );
            } else {
              return LogIn();
            }
          }
        },
      ),
      routes: {
        "signup": (context) => SignUp(),
        "login": (context) => LogIn(),
        "homepage": (context) => HomePage(),
        "addcategory": (context) => AddCategory(),
        "home": (context) => Home(),
        "settings":
            (context) => Setting(
              isDark: _themeMode == ThemeMode.dark,
              onToggleTheme: _toggleTheme,
            ),
        "profile": (context) => studentProfile(),
        "editprofile": (context) => Editprofile(),
        "uploadcv": (context) => UploadCV(),
        "showcv": (context) => ViewCV(),
        "companyprofile": (context) => CompanyProfile(),
        "companyhome": (context) => CompanyHome(),
        "editcprofile": (context) => EditCProfile(),
        "companysettings":
            (context) => CompanySettings(
              isDark: _themeMode == ThemeMode.dark,
              onToggleTheme: _toggleTheme,
            ),
        "adminhome": (context) => adminHome(),
        "enterinfo": (context) => EnterInfo(),
        'applications': (context) => ApplicationsPage(),
      },
    );
  }
}
