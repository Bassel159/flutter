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

  String? selectedUniversity;
  String? selectedMajor;
  String? selectedGPA;
  String? selectedYear;
  String? selectedGrad;
  String? selectedPref;

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

  bool isSaving = false;

  Future<void> saveUserInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'university': selectedUniversity,
        'major': selectedMajor,
        'gpa': selectedGPA,
        'yearofstudy': selectedYear,
        'expectedgrad': selectedGrad,
        'preferredindustry': selectedPref,
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
          title: Text("Enter Information"),
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
                SizedBox(height: 20),
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
                SizedBox(height: 20),
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
                SizedBox(height: 20),
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
                SizedBox(height: 20),
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
