import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Editprofile extends StatefulWidget {
  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  TextEditingController nameController = TextEditingController();
  TextEditingController majorController = TextEditingController();
  TextEditingController universityController = TextEditingController();

  bool isLoading = true;

  Future<void> loadUserData() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      nameController.text = data['studentName'] ?? '';
      majorController.text = data['major'] ?? '';
      universityController.text = data['university'] ?? '';
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveChanges() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'studentName': nameController.text,
      'major': majorController.text,
      'university': universityController.text,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Editprofile updated successfully')));
    Navigator.of(context).pop(true);
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editprofile")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: "Name"),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: majorController,
                      decoration: InputDecoration(labelText: "Major"),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: universityController,
                      decoration: InputDecoration(labelText: "University"),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: saveChanges,
                      child: Text("Save Changes"),
                    ),
                  ],
                ),
              ),
    );
  }
}
