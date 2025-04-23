import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/customformfield.dart';
import '../components/customlogoauth.dart';
import '../components/custombuttonauth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUp extends StatefulWidget{
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp>{
  String userType = 'Student';
  // For All
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  // For student
  TextEditingController studentName = TextEditingController();
  TextEditingController university = TextEditingController();
  TextEditingController major = TextEditingController();
  // For company
  TextEditingController companyName = TextEditingController();
  TextEditingController industry = TextEditingController();

  GlobalKey<FormState> formState = GlobalKey<FormState>();
// Disposing controllers
  @override
  void dispose() {
    // TODO: implement dispose
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
        child: ListView(children: [
          Form(
            key: formState,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 50,),
                Customlogoauth(),
                Container(height: 20,),
                Text("SignUp",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold)),
                Container(height: 10,),
                Text("SignUp to continue",style: TextStyle(color: Colors.grey),),
                Container(height: 20,),
                //Dropdownbutton
                Text("Account Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                    items: ['Student', 'Company'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),  // Text in the dropdown
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        userType = val!;  // Update the userType when changed
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                // Student. . . . .
                if (userType == 'Student') ...[
                  Text("Student Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Container(height: 20),
                  CustomTextForm(
                    hinttext: "Enter your Name",
                    mycontroller: studentName,
                    validator: (val) {
                      if (val == "") return "Enter something";
                    },
                  ),
                  Container(height: 20),
                  Text("University", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Container(height: 20),
                  CustomTextForm(
                    hinttext: "Enter your University",
                    mycontroller: university,
                    validator: (val) {
                      if (val == "") return "Enter something";
                    },
                  ),
                  Container(height: 20),
                  Text("Major", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Container(height: 20),
                  CustomTextForm(
                    hinttext: "Enter your Major",
                    mycontroller: major,
                    validator: (val) {
                      if (val == "") return "Enter something";
                    },
                  ),
                ],
                // Company. . . . .
                if (userType == 'Company') ...[
                  Text("Company Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Container(height: 20),
                  CustomTextForm(
                    hinttext: "Enter your Company Name",
                    mycontroller: companyName,
                    validator: (val) {
                      if (val == "") return "Enter something";
                    },
                  ),
                  Container(height: 20),
                  Text("Industry", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Container(height: 20),
                  CustomTextForm(
                    hinttext: "Enter your Industry",
                    mycontroller: industry,
                    validator: (val) {
                      if (val == "") return "Enter something";
                    },
                  ),
                ],

                // Email and Password fields
                Container(height: 20,),
                Text("Email",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                Container(height: 20,),
                CustomTextForm(hinttext: "Enter your Email", mycontroller: email,validator: (val){
                  if(val == ""){
                    return "Enter something";
                  }}),
                Container(height: 20,),
                Text("Password",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                Container(height: 20,),
                CustomTextForm(hinttext: "Enter your Password", mycontroller: password,validator: (val){
                  if(val == ""){
                    return "Enter something";
                  }}),
                Container(height: 20,),

              ],),
          ),
          Custombuttonauth(title: "SignUp",onPressed: () async{
            if(formState.currentState!.validate()){
              try {
                final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email.text,
                  password: password.text,
                );
                // Send User Information to Firebase
                await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
                  'email': email.text,
                  'userType': userType,
                  if (userType == 'Student') ...{
                    'studentName': studentName.text,
                    'university': university.text,
                    'major': major.text,
                    'companyName': null,
                    'industry': null,
                  } else ...{
                    'studentName': null,
                    'university': null,
                    'major': null,
                    'companyName': companyName.text,
                    'industry': industry.text,
                  }
                });
                // Navigate to Login and catch errors
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
          },),
          Container(height: 20,),
          InkWell(
            onTap: (){
              Navigator.of(context).pushNamed("login");
            },
            child: Center(
              child: Text.rich(TextSpan(children: [
                TextSpan(text: "If you already have an account ",),
                TextSpan(text: "LogIn",style: TextStyle(color: Colors.blue)),
              ])
              ),
            ),
          )
        ],),
      ),
    );
  }
}