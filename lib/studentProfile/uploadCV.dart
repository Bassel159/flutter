import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class UploadCV extends StatefulWidget {
  const UploadCV({super.key});

  @override
  _UploadCVState createState() => _UploadCVState();
}

class _UploadCVState extends State<UploadCV> {
  String? _statusMessage;
  String? cvUrl;
  bool isLoading = true;
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

  Future<void> pickAndUploadPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final fileName = 'cv_$uid.pdf';
      final storageRef = FirebaseStorage.instance.ref().child('cvs/$fileName');

      try {
        // 1. حذف الملف القديم إن وجد
        await storageRef.delete().catchError((e) {
          print("⚠️ لم يتم حذف الملف القديم أو غير موجود: $e");
        });

        // 2. رفع الملف الجديد بنفس الاسم
        UploadTask uploadTask = storageRef.putFile(file);
        TaskSnapshot snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
          final downloadUrl = await snapshot.ref.getDownloadURL();

          // 3. حفظ الرابط مرة واحدة فقط (أو تجاهله إذا محفوظ مسبقًا)
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'cv_url': downloadUrl,
            'uploaded_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          setState(() {
            _statusMessage = '✅ تم رفع السيرة الذاتية بنجاح واستبدال القديمة.';
            cvUrl = downloadUrl;
          });
        } else {
          setState(() {
            _statusMessage = '❌ فشل في رفع الملف.';
          });
        }
      } catch (e) {
        setState(() {
          _statusMessage = '❌ خطأ أثناء رفع الملف أو حذفه: $e';
        });
      }
    } else {
      setState(() {
        _statusMessage = 'لم يتم اختيار أي ملف.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Your CV"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 30,
          children: [
            SizedBox(height: 100),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.upload_file, color: Colors.white),
                label: Text(
                  'Upload Your CV',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: pickAndUploadPDF,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.upload_file, color: Colors.white),
                label: Text(
                  'Show Your CV',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: () {
                  openCV();
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        _statusMessage!.contains('✅')
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
