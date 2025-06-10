import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class studentProfile extends StatefulWidget {
  const studentProfile({super.key});

  @override
  State<studentProfile> createState() => _studentProfileState();
}

class _studentProfileState extends State<studentProfile> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  String nameStudent = "";
  String major = "";
  String university = "";
  String email = "";
  String gpa = "";
  String yearofstudy = "";
  String expectedgrad = "";
  String prefindustry = "";
  bool isLoading = true;

  Future<void> loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        throw Exception("User not logged in");
      }

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();

      if (data != null) {
        setState(() {
          nameStudent = data['studentName'] ?? '';
          major = data['major'] ?? '';
          university = data['university'] ?? '';
          email = data['email'] ?? '';
          gpa = data['gpa'] ?? '';
          yearofstudy = data['yearofstudy'] ?? '';
          expectedgrad = data['expectedgrad'] ?? '';
          prefindustry = data['preferredindustry'] ?? '';
          isLoading = false;
        });
      } else {
        throw Exception("User data not found");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[300],
      appBar: AppBar(
        title: Text("My Profile"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.deepPurple[100],
                        child: Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      nameStudent,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[800],
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Student",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple[300],
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 30),

                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      shadowColor: Colors.deepPurple.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 25,
                        ),
                        child: Column(
                          children: [
                            _buildProfileItem(
                              icon: Icons.account_balance,
                              title: "University",
                              value: university,
                            ),
                            Divider(height: 35, thickness: 1.2),
                            _buildProfileItem(
                              icon: Icons.school,
                              title: "Major",
                              value: major,
                            ),
                            Divider(height: 35, thickness: 1.2),
                            _buildProfileItem(
                              icon: Icons.email,
                              title: "Email",
                              value: email,
                            ),
                            Divider(height: 35, thickness: 1.2),
                            _buildProfileItem(
                              icon: Icons.star,
                              title: "GPA",
                              value: gpa,
                            ),
                            Divider(height: 35, thickness: 1.2),
                            _buildProfileItem(
                              icon: Icons.calendar_today,
                              title: "Year of Study",
                              value: yearofstudy,
                            ),
                            Divider(height: 35, thickness: 1.2),
                            _buildProfileItem(
                              icon: Icons.event,
                              title: "Expected Graduation",
                              value: expectedgrad,
                            ),
                            Divider(height: 35, thickness: 1.2),
                            _buildProfileItem(
                              icon: Icons.work,
                              title: "Preferred Industry",
                              value: prefindustry,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.of(
                            context,
                          ).pushNamed("uploadcv");
                          if (result == true) {
                            loadUserData();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                          backgroundColor: Colors.deepPurple,
                          shadowColor: Colors.deepPurpleAccent,
                        ),
                        child: Text(
                          'Upload Your CV',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          final result = await Navigator.of(
                            context,
                          ).pushNamed("editprofile");
                          if (result == true) {
                            loadUserData();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.deepPurple, width: 2),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: Colors.deepPurple,
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        child: Text('Edit Profile'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.deepPurple, size: 28),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.deepPurple[300],
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
