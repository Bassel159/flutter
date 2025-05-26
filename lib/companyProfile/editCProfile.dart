import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCProfile extends StatefulWidget {
  const EditCProfile({super.key});

  @override
  State<EditCProfile> createState() => _EditCProfileState();
}

class _EditCProfileState extends State<EditCProfile> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  String? selectedLocation;
  String? selectedIndustry;

  bool isLoading = true;
  bool isSaving = false;

  final List<String> prefind = [
    "Mobile Development",
    "Web Development",
    "Software Development",
    "Frontend Development",
    "Backend Development",
    "Full Stack Development",
    "DevOps Engineering",
    "Database Administration",
    "Network Engineering",
    "Cloud Engineering",
    "Data Science",
    "QA Engineering",
    "Cybersecurity",
  ];
  final List<String> location = [
    "Ajloun",
    "Amman",
    "Aqaba",
    "Balqa",
    "Irbid",
    "Jerash",
    "Karak",
    "Ma'an",
    "Madaba",
    "Mafraq",
    "Tafilah",
    "Zarqa",
  ];

  Future<void> loadUserData() async {
    try {
      final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          nameController.text = data['companyName'] ?? '';
          selectedIndustry = data['industry'] ?? '';
          selectedLocation = data['location'] ?? '';
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

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'companyName': nameController.text.trim(),
        'industry': selectedIndustry,
        'location': selectedLocation,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
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
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Color.fromARGB(255, 72, 144, 180);

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Company Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: mainColor,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Update Company Information",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
              SizedBox(height: 30),

              // Company Name Field
              _buildTextField(
                controller: nameController,
                label: "Company Name",
                icon: Icons.business,
                color: mainColor,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the company name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Industry Field
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: "Choose your Industry",
                  border: OutlineInputBorder(),
                ),
                value: selectedIndustry,
                items: prefind.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedIndustry = value;
                  });
                },
              ),
              SizedBox(height: 40),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: "Choose your Location",
                  border: OutlineInputBorder(),
                ),
                value: selectedLocation,
                items: location.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value;
                  });
                },
              ),
              SizedBox(height: 40),
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSaving ? null : saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isSaving
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "SAVE CHANGES",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Cancel Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      validator: validator,
    );
  }
}
