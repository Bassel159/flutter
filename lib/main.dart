import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:internseek/auth/signup.dart';
import 'package:internseek/categories/add.dart';
import 'package:internseek/home.dart';
import 'package:internseek/profile.dart';
import 'package:internseek/settings.dart';
import 'categories/edit.dart';
import 'auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState(){
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
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
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              backgroundColor: Colors.purple,
              titleTextStyle: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold,),
              iconTheme:IconThemeData(color: Colors.white)
          )
      ),
      debugShowCheckedModeBanner: false,
      home: (FirebaseAuth.instance.currentUser != null &&
          FirebaseAuth.instance.currentUser!.emailVerified)?Home(): LogIn(),
      routes: {
        "signup" : (context) => SignUp(),
        "login" : (context) => LogIn(),
        "homepage" : (context) => HomePage(),
        "addcategory" : (context) => AddCategory(),
        "home" : (context) => Home(),
        "settings" : (context) => Settings(),
        "profile" : (context) => Profile(),
      },
    );
  }
}