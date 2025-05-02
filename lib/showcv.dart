import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewCVPage extends StatefulWidget {
  const ViewCVPage({super.key});

  @override
  _ViewCVPageState createState() => _ViewCVPageState();
}

class _ViewCVPageState extends State<ViewCVPage> {
  String? cvUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCVUrl();
  }

  Future<void> fetchCVUrl() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          cvUrl = doc.data()!['cv_url'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('خطأ في جلب الرابط: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openCV() async {
    if (cvUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ لا يوجد رابط للسيرة الذاتية")));
      return;
    }

    final uri = Uri.parse(cvUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.platformDefault, // أو LaunchMode.inAppWebView
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ لا يمكن فتح الرابط")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("عرض السيرة الذاتية"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child:
            isLoading
                ? CircularProgressIndicator()
                : cvUrl == null
                ? Text("❌ لا توجد سيرة ذاتية مرفوعة")
                : ElevatedButton.icon(
                  onPressed: openCV,
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text("عرض السيرة الذاتية"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
      ),
    );
  }
}
