import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final _formKey = GlobalKey<FormState>();
  String? selectedUniversity;
  String? selectedMajor;
  String? selectedGPA;
  String? selectedYear;
  String? selectedGrad;
  String? selectedPref;

  TextEditingController nameController = TextEditingController();


  bool isLoading = true;
  bool isSaving = false;

  final List<String> universities = [
    "Ajloun National University",
    "Al al-Bayt University",
    "Al-Ahliyya Amman University",
    "Al-Balqa Applied University",
    "Al-Hussein Bin Talal University",
    "Al Hussein Technical University",
    "Al-Isra University",
    "Al-Zaytoonah University of Jordan",
    "American University of Madaba",
    "Amman Arab University",
    "Aqaba Medical Sciences University",
    "Aqaba University of Technology",
    "Applied Science Private University",
    "Arab Academy for Banking and Financial Sciences",
    "Arab Open University",
    "Columbia University: Amman Branch",
    "German-Jordanian University",
    "Hashemite University",
    "Ibn Sina University for Medical Sciences",
    "Irbid National University",
    "Jadara University",
    "Jerash Private University",
    "Jordan Academy for Maritime Studies",
    "Jordan Academy of Music",
    "Jordan Institute of Banking Studies",
    "Jordan Media Institute",
    "Jordan University of Science and Technology",
    "Luminus Technical University College",
    "Middle East University",
    "Mutah University",
    "National University College of Technology",
    "New York Institute of Technology, Madaba",
    "Petra University",
    "Philadelphia University",
    "Princess Sumaya University for Technology",
    "Queen Noor Civil Aviation Technical College",
    "Tafila Technical University",
    "The World Islamic Science & Education University (W.I.S.E)",
    "University of Jordan",
    "Yarmouk University",
    "Zarqa University",
  ];
  final List<String> Majors = [
    "Computer Science",
    "Software Engineering",
    "Cybersecurity",
    "Data Science",
    "Artificial Intelligence",
    "Computer Engineering",
    "Computer Information Systems",
    "Game Development",
  ];
  final List<String> GPA = [
    "Distinguished",
    "Excellent",
    "Very Good",
    "Good",
    "Fair",
  ];
  final List<String> year = [
    "1st Year",
    "2nd Year",
    "3rd Year",
    "4th Year",
    "5th Year"
  ];
  final List<String> gradyear = [
    "2025","2026","2027","2028","2029","2030","2031",
  ];
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

  Future<void> loadUserData() async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          nameController.text = data['studentName'] ?? '';
          selectedMajor = data['major'] ?? '';
          selectedGPA = data['gpa'] ?? '';
          selectedUniversity = data['university'] ?? '';
          selectedYear = data['yearofstudy'] ?? '';
          selectedGrad = data['expectedgrad'] ?? '';
          selectedPref = data['preferredindustry'] ?? '';
          isLoading = false;
        });
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

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'studentName': nameController.text.trim(),
        'major': selectedMajor,
        'university': selectedUniversity,
        'gpa': selectedGPA,
        'yearofstudy': selectedYear,
        'expectedgrad': selectedGrad,
        'preferredindustry': selectedPref,
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Header
                      Text(
                        "Update Your Information",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 30),

                      // Name Field
                      _buildTextField(
                        controller: nameController,
                        label: "Full Name",
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Major Field
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Choose your University",
                          border: OutlineInputBorder(),
                        ),
                        value: selectedUniversity,
                        items: universities.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUniversity = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      // University Field
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Choose your Major",
                          border: OutlineInputBorder(),
                        ),
                        value: selectedMajor,
                        items: Majors.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMajor = value;
                          });
                        },
                      ),
                      SizedBox(height: 40),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Choose your GPA",
                          border: OutlineInputBorder(),
                        ),
                        value: selectedGPA,
                        items: GPA.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGPA = value;
                          });
                        },
                      ),
                      SizedBox(height: 40),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Choose your Year of Study",
                          border: OutlineInputBorder(),
                        ),
                        value: selectedYear,
                        items: year.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value;
                          });
                        },
                      ),
                      SizedBox(height: 40),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Choose your Expected Graduation",
                          border: OutlineInputBorder(),
                        ),
                        value: selectedGrad,
                        items: gradyear.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGrad = value;
                          });
                        },
                      ),
                      SizedBox(height: 40),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Choose your Preferred Industry",
                          border: OutlineInputBorder(),
                        ),
                        value: selectedPref,
                        items: prefind.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPref = value;
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
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child:
                              isSaving
                                  ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
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
                            color: Colors.deepPurple,
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
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      validator: validator,
    );
  }
}
