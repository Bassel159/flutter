import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internseek/components/custombuttonauth.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  String nameStudent = "";
  String major = "";
  String university = "";
  String email = "";
  bool isLoading = true;

  Future<void> loadUserData() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      nameStudent = data['studentName'] ?? '';
      major = data['major'] ?? '';
      university = data['university'] ?? '';
      email = data['email'] ?? '';
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveChanges() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'studentName': nameStudent,
      'major': major,
      'university': university,
      'email': email,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile"), centerTitle: true),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(height: 100),
                    Row(
                      children: [
                        Container(
                          child: Text(
                            "Student Name : $nameStudent",
                            style: TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 20),
                    Row(
                      children: [
                        Container(
                          child: Text(
                            "University : $university",
                            style: TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 20),
                    Row(
                      children: [
                        Container(
                          child: Text(
                            "Major : $major",
                            style: TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 20),
                    Row(
                      children: [
                        Container(
                          child: Text(
                            "Email : $email",
                            style: TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 100),
                    Custombuttonauth(
                      title: 'Edit Your Information',
                      onPressed: () async {
                        final result = await Navigator.of(
                          context,
                        ).pushNamed("editprofile");

                        if (result == true) {
                          // ✅ إعادة تحميل البيانات بعد التعديل
                          loadUserData();
                        }
                      },
                    ),
                  ],
                ),
              ),
    );
  }
}
