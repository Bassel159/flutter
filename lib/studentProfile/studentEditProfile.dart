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

  final Color mainColor = Colors.deepPurple;

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
    "5th Year",
  ];
  final List<String> gradyear = [
    "2025",
    "2026",
    "2027",
    "2028",
    "2029",
    "2030",
    "2031",
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
    if (uid == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          nameController.text = data['studentName'] ?? '';
          selectedMajor = data['major'];
          selectedGPA = data['gpa'];
          selectedUniversity = data['university'];
          selectedYear = data['yearofstudy'];
          selectedGrad = data['expectedgrad'];
          selectedPref = data['preferredindustry'];
          isLoading = false;
        });
      } else {
        setState(() {
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: mainColor) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items:
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      onChanged: onChanged,
      validator:
          (val) => val == null || val.isEmpty ? 'Please select $label' : null,
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
        prefixIcon: Icon(icon, color: mainColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: mainColor,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Update Your Information",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: nameController,
                                label: "Full Name",
                                icon: Icons.person,
                                validator:
                                    (value) =>
                                        (value == null || value.isEmpty)
                                            ? 'Please enter your name'
                                            : null,
                              ),
                              const SizedBox(height: 20),
                              _buildDropdown(
                                label: "Choose your University",
                                value: selectedUniversity,
                                items: universities,
                                onChanged:
                                    (val) => setState(
                                      () => selectedUniversity = val,
                                    ),
                                icon: Icons.school,
                              ),
                              const SizedBox(height: 20),
                              _buildDropdown(
                                label: "Choose your Major",
                                value: selectedMajor,
                                items: Majors,
                                onChanged:
                                    (val) =>
                                        setState(() => selectedMajor = val),
                                icon: Icons.computer,
                              ),
                            ],
                          ),
                        ),
                      ),

                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildDropdown(
                                label: "Choose your GPA",
                                value: selectedGPA,
                                items: GPA,
                                onChanged:
                                    (val) => setState(() => selectedGPA = val),
                                icon: Icons.grade,
                              ),
                              const SizedBox(height: 20),
                              _buildDropdown(
                                label: "Choose your Year of Study",
                                value: selectedYear,
                                items: year,
                                onChanged:
                                    (val) => setState(() => selectedYear = val),
                                icon: Icons.calendar_today,
                              ),
                              const SizedBox(height: 20),
                              _buildDropdown(
                                label: "Choose your Expected Graduation",
                                value: selectedGrad,
                                items: gradyear,
                                onChanged:
                                    (val) => setState(() => selectedGrad = val),
                                icon: Icons.school_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),

                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.only(bottom: 32),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildDropdown(
                            label: "Preferred Industry",
                            value: selectedPref,
                            items: prefind,
                            onChanged:
                                (val) => setState(() => selectedPref = val),
                            icon: Icons.business_center,
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon:
                                  isSaving
                                      ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Icon(Icons.save),
                              label: Text(
                                isSaving ? "Saving..." : "Save Changes",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: isSaving ? null : saveChanges,
                            ),
                          ),
                          const SizedBox(width: 15),
                          OutlinedButton.icon(
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.deepPurple,
                            ),
                            label: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.deepPurple),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: mainColor, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
