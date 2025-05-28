import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:internseek/ApplicationsPage.dart';
import 'package:internseek/auth/signup.dart';
import 'package:internseek/categories/add.dart';
import 'package:internseek/companyProfile/adminSetting.dart';
import 'package:internseek/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'companyProfile/adminHome.dart';
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
import 'components/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // استرجاع خيار الثيم من SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkTheme') ?? false;

  runApp(MyApp(isDark: isDark));
}

ThemeData getThemeForUserType(String userType, bool isDarkMode) {
  switch (userType.toLowerCase()) {
    case 'admin':
      return getAdminTheme(isDarkMode);
    case 'student':
      return getStudentTheme(isDarkMode);
    case 'company':
      return getCompanyTheme(isDarkMode);
    default:
      return isDarkMode ? ThemeData.dark() : ThemeData.light();
  }
}

class MyApp extends StatefulWidget {
  final bool isDark;

  const MyApp({super.key, required this.isDark});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.isDark ? ThemeMode.dark : ThemeMode.light;

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('==================User is currently signed out!');
      } else {
        print('=================User is signed in!');
      }
    });
  }

  void _toggleTheme(bool isDark) async {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.purple,
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
        primarySwatch: Colors.purple,
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
      home: SplashScreen(),
      routes: {
        "signup": (context) => SignUp(),
        "login": (context) => LogIn(),
        "homepage": (context) => HomePage(),
        "addcategory": (context) => AddCategory(),
        "home": (context) => Home(userType: 'Student'), // مثال تمرير userType
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
        "adminsettings":
            (context) => AdminSettings(
              isDark: _themeMode == ThemeMode.dark,
              onToggleTheme: _toggleTheme,
            ),
      },
    );
  }
}
