import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/customformfield.dart';
import '../components/customlogoauth.dart';
import '../components/custombuttonauth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String userType = 'Student';
  String? selectedUniversity;
  String? selectedMajor;
  String? selectedGPA;
  String? selectedYear;
  String? selectedGrad;
  String? selectedPref;
  String? selectedLocation;
  String? selectedIndustry;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  TextEditingController studentName = TextEditingController();

  TextEditingController companyName = TextEditingController();

  GlobalKey<FormState> formState = GlobalKey<FormState>();

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




  @override
  void dispose() {
    super.dispose();
    studentName.dispose();
    email.dispose();
    password.dispose();
    companyName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Form(
              key: formState,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Customlogoauth(),
                  SizedBox(height: 20),
                  Text(
                    "SignUp",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "SignUp to continue",
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Account Type",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey[200],
                    ),
                    child: DropdownButton<String>(
                      value: userType,
                      isExpanded: true,
                      underline: SizedBox(),
                      items:
                          ['Student', 'Company'].map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          userType = val!;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),

                  // Student Fields
                  if (userType == 'Student') ...[
                    _buildLabel("Student Name"),
                    CustomTextForm(
                      hinttext: "Enter your Name",
                      mycontroller: studentName,
                      validator:
                          (val) => val!.isEmpty ? "Enter something" : null,
                    ),
                    SizedBox(height: 20),           //University

                    _buildLabel("University"),
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
                    SizedBox(height: 20),               //Major

                    _buildLabel("Major"),
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

                    SizedBox(height: 20),             //GPA
                    _buildLabel("GPA"),
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
                    SizedBox(height: 20),           //Year of Study
                    _buildLabel("Year of Study"),
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
                    SizedBox(height: 20),             //Expected Graduation
                    _buildLabel("Expected Graduation"),
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
                          child: Text(item.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGrad = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),             //Preferred Industry
                    _buildLabel("Preferred Industry"),
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
                  ],

                  // Company Fields
                  if (userType == 'Company') ...[
                    _buildLabel("Company Name"),
                    CustomTextForm(
                      hinttext: "Enter your Company Name",
                      mycontroller: companyName,
                      validator:
                          (val) => val!.isEmpty ? "Enter something" : null,
                    ),
                    SizedBox(height: 20),               //Industry
                    _buildLabel("Industry"),
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
                    _buildLabel("Location"),                //Location
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
                  ],

                  SizedBox(height: 20),
                  _buildLabel("Email"),
                  CustomTextForm(
                    hinttext: "Enter your Email",
                    mycontroller: email,
                    validator: (val) => val!.isEmpty ? "Enter something" : null,
                  ),
                  SizedBox(height: 20),
                  _buildLabel("Password"),
                  CustomTextForm(
                    hinttext: "Enter your Password",
                    mycontroller: password,
                    validator: (val) => val!.isEmpty ? "Enter something" : null,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Custombuttonauth(
              title: "SignUp",
              onPressed: () async {
                if (formState.currentState!.validate()) {
                  try {
                    final credential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                          email: email.text,
                          password: password.text,
                        );

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(credential.user!.uid)
                        .set({
                          'email': email.text,
                          'userType': userType,
                          if (userType == 'Student') ...{
                            'studentName': studentName.text,
                            'university': selectedUniversity,
                            'major': selectedGrad,
                            'gpa': selectedGPA,
                            'yearofstudy': selectedYear,
                            'expectedgrad': selectedGrad,
                            'prefindustry': selectedPref,
                          } else ...{
                            'companyName': companyName.text,
                            'industry': selectedIndustry,
                            'location': selectedLocation,
                            'requestedCompany': true,
                            'isApproved': false,
                          },
                        });

                    Navigator.of(context).pushReplacementNamed("login");
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'weak-password') {
                      print('The password provided is too weak.');
                    } else if (e.code == 'email-already-in-use') {
                      print('The account already exists for that email.');
                    }
                  } catch (e) {
                    print(e);
                  }
                }
              },
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed("login");
              },
              child: Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "If you already have an account "),
                      TextSpan(
                        text: "LogIn",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
