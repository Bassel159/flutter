import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyProfile extends StatefulWidget {
  const CompanyProfile({super.key});

  @override
  State<CompanyProfile> createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<CompanyProfile> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  String companyName = "";
  String industry = "";
  String email = "";
  bool isLoading = true;

  Future<void> loadUserData() async {
    try {
      final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          companyName = data['companyName'] ?? '';
          industry = data['industry'] ?? '';
          email = data['email'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color.fromARGB(255, 72, 144, 180);

    return Scaffold(
      appBar: AppBar(
        title: Text("Company Profile"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              margin: EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: mainColor.withOpacity(0.1),
                    child: Icon(
                      Icons.business,
                      size: 50,
                      color: mainColor,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    companyName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  Text(
                    industry,
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
                      icon: Icons.business,
                      title: "Company Name",
                      value: companyName,
                      color: mainColor,
                    ),
                    Divider(height: 30),
                    _buildProfileItem(
                      icon: Icons.category,
                      title: "Industry",
                      value: industry,
                      color: mainColor,
                    ),
                    Divider(height: 30),
                    _buildProfileItem(
                      icon: Icons.email,
                      title: "Email",
                      value: email,
                      color: mainColor,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Edit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result =
                  await Navigator.of(context).pushNamed("editcprofile");
                  if (result == true) {
                    loadUserData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
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
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 28),
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
