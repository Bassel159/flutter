import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:internseek/auth/login.dart';
import 'package:internseek/companyProfile/adminHome.dart';
import 'package:internseek/companyProfile/companyHome.dart';
import 'package:internseek/components/customlogoauth.dart';
import 'package:internseek/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    initialize();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  Future<void> initialize() async {
    await Firebase.initializeApp();
    await Future.delayed(const Duration(seconds: 5));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final userType = userDoc.data()?['userType'] ?? 'Student';

      if (userType == 'Company') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CompanyHome()),
        );
      } else if (userType == 'Admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const adminHome()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home(userType: userType)),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LogIn()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Customlogoauth(),
            const SizedBox(height: 20),
            const Text(
              "InternSeek",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Developed by:",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              "Ramzi Sultan\nBassel Abdelhadi\nOmar Awad\nFaisal Telfah",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF34495E),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
