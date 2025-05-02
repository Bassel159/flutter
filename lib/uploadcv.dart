import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class UploadCVPage extends StatefulWidget {
  @override
  _UploadCVPageState createState() => _UploadCVPageState();
}

class _UploadCVPageState extends State<UploadCVPage> {
  String? _statusMessage;

  Future<void> pickAndUploadPDF() async {
    // اختيار الملف باستخدام FilePicker
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    // التحقق إذا تم اختيار ملف
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String fileName = 'cv_${DateTime.now().millisecondsSinceEpoch}.pdf';

      try {
        // رفع الملف إلى Firebase Storage
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('cvs/$fileName')
            .putFile(file);

        // انتظار اكتمال عملية الرفع
        TaskSnapshot snapshot = await uploadTask;

        // التحقق من حالة الرفع
        if (snapshot.state == TaskState.success) {
          String downloadUrl = await snapshot.ref.getDownloadURL();

          // الحصول على UID المستخدم الحالي
          String uid = FirebaseAuth.instance.currentUser!.uid;

          // حفظ الرابط في Firestore
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'cv_url': downloadUrl,
            'uploaded_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)); // دمج البيانات إذا كان الحقل موجودًا

          setState(() {
            _statusMessage = '✅ تم رفع السيرة الذاتية بنجاح وحفظ الرابط.';
          });
        } else {
          setState(() {
            _statusMessage = '❌ حدث خطأ أثناء الرفع.';
          });
        }
      } catch (e) {
        // التعامل مع الأخطاء أثناء الرفع أو الحفظ
        setState(() {
          _statusMessage = '❌ حدث خطأ أثناء الرفع أو الحفظ: $e';
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
      appBar: AppBar(title: Text('رفع السيرة الذاتية')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: pickAndUploadPDF,
              icon: Icon(Icons.upload_file),
              label: Text('اختر وارفـع ملف PDF'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed("showcv");
              },
              icon: Icon(Icons.upload_file),
              label: Text('اعرض السيرة الذاتية'),
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
