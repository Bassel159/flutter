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

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  TextEditingController studentName = TextEditingController();
  TextEditingController university = TextEditingController();
  TextEditingController major = TextEditingController();

  TextEditingController companyName = TextEditingController();
  TextEditingController industry = TextEditingController();

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    studentName.dispose();
    email.dispose();
    password.dispose();
    university.dispose();
    major.dispose();
    companyName.dispose();
    industry.dispose();
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
                    SizedBox(height: 20),
                    _buildLabel("University"),
                    CustomTextForm(
                      hinttext: "Enter your University",
                      mycontroller: university,
                      validator:
                          (val) => val!.isEmpty ? "Enter something" : null,
                    ),
                    SizedBox(height: 20),
                    _buildLabel("Major"),
                    CustomTextForm(
                      hinttext: "Enter your Major",
                      mycontroller: major,
                      validator:
                          (val) => val!.isEmpty ? "Enter something" : null,
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
                    SizedBox(height: 20),
                    _buildLabel("Industry"),
                    CustomTextForm(
                      hinttext: "Enter your Industry",
                      mycontroller: industry,
                      validator:
                          (val) => val!.isEmpty ? "Enter something" : null,
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
                        'university': university.text,
                        'major': major.text,
                        'companyName': null,
                        'industry': null,
                        'requestedCompany': false,
                        'isApproved': false,
                      } else ...{
                        'studentName': null,
                        'university': null,
                        'major': null,
                        'companyName': companyName.text,
                        'industry': industry.text,
                        'requestedCompany': true,
                        'isApproved': false, // وضع القيمة الافتراضية هنا
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