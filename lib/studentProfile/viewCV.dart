import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewCV extends StatefulWidget {
  const ViewCV({super.key});

  @override
  _ViewCVState createState() => _ViewCVState();
}

class _ViewCVState extends State<ViewCV> {
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
      print('Error in URL: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openCV() async {
    if (cvUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ URL not found")));
      return;
    }

    final uri = Uri.parse(cvUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Cannot open URL")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Show CV"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child:
            isLoading
                ? CircularProgressIndicator()
                : cvUrl == null
                ? Text("❌ No CV found")
                : ElevatedButton.icon(
                  onPressed: openCV,
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text("Show CV"),
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
