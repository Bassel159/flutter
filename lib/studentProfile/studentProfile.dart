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
      appBar: AppBar(
        title: Text("My Profile"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Header with Avatar
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.deepPurple[100],
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            nameStudent,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Text(
                            "Student",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Profile Details Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildProfileItem(
                              icon: Icons.account_balance,
                              title: "University",
                              value: university,
                            ),
                            Divider(height: 30),
                            _buildProfileItem(
                              icon: Icons.school,
                              title: "Major",
                              value: major,
                            ),
                            Divider(height: 30),
                            _buildProfileItem(
                              icon: Icons.email,
                              title: "Email",
                              value: email,
                            ),
                            Divider(height: 30),
                            _buildProfileItem(
                              icon: Icons.star,
                              title: "GPA",
                              value: gpa,
                            ),
                            Divider(height: 30),
                            _buildProfileItem(
                              icon: Icons.calendar_today,
                              title: "Year of Study",
                              value: yearofstudy,
                            ),
                            Divider(height: 30),
                            _buildProfileItem(
                              icon: Icons.event,
                              title: "Expected Graduation",
                              value: expectedgrad,
                            ),
                            Divider(height: 30),
                            _buildProfileItem(
                              icon: Icons.work,
                              title: "Preferred Industry",
                              value: prefindustry,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30),
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
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Upload Your CV',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Edit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.of(
                            context,
                          ).pushNamed("editprofile");
                          if (result == true) {
                            loadUserData();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
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
        Icon(icon, color: Colors.deepPurple, size: 28),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
