import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnterInfo extends StatefulWidget {
  const EnterInfo({super.key});

  @override
  State<EnterInfo> createState() => _EnterInfoState();
}

class _EnterInfoState extends State<EnterInfo> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final _formKey = GlobalKey<FormState>();

  TextEditingController universityController = TextEditingController();
  TextEditingController majorController = TextEditingController();
  TextEditingController gpaController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController gradController = TextEditingController();
  TextEditingController prefController = TextEditingController();

  bool isSaving = false;

  Future<void> saveUserInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'university': universityController.text.trim(),
        'major': majorController.text.trim(),
        'gpa': gpaController.text.trim(),
        'yearofstudy': yearController.text.trim(),
        'expectedgrad': gpaController.text.trim(),
        'preferredindustry': prefController.text.trim(),
        'userType': 'Student',
      }, SetOptions(merge: true)); // merge avoids overwriting existing data

      Navigator.pushReplacementNamed(context, 'home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving info: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        appBar: AppBar(
          title: Text("Enter Info"),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
          automaticallyImplyLeading: false, // Hide back arrow
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: universityController,
                  label: "University",
                  icon: Icons.account_balance,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: majorController,
                  label: "Major / Field of Study",
                  icon: Icons.school,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: gpaController,
                  label: "GPA",
                  icon: Icons.grade,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: yearController,
                  label: "Year of Study",
                  icon: Icons.school,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: gradController,
                  label: "Expected Graduation",
                  icon: Icons.school,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: prefController,
                  label: "Preferred Industry",
                  icon: Icons.school,
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : saveUserInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        isSaving
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              "SAVE DATA",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}
