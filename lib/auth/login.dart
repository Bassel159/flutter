import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../components/customformfield.dart';
import '../components/customlogoauth.dart';
import '../components/custombuttonauth.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  GlobalKey<FormState> formState = GlobalKey<FormState>();
  bool isLoading = false;

  Future signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.of(context).pushNamedAndRemoveUntil("home", (route) => false);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    email.dispose();
    password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading == true
              ? Center(child: CircularProgressIndicator())
              : Container(
                padding: EdgeInsets.all(20),
                child: ListView(
                  children: [
                    Form(
                      key: formState,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 50),
                          Customlogoauth(),
                          Container(height: 20),
                          Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(height: 10),
                          Text(
                            "Login to continue",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Container(height: 20),
                          Text(
                            "Email",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Container(height: 20),
                          CustomTextForm(
                            hinttext: "Enter your Email",
                            mycontroller: email,
                            validator: (val) {
                              if (val == "") {
                                return "Enter something";
                              }
                              return null;
                            },
                          ),
                          Container(height: 20),
                          Text(
                            "Password",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Container(height: 20),
                          CustomTextForm(
                            hinttext: "Enter your Password",
                            mycontroller: password,
                            validator: (val) {
                              if (val == "") {
                                return "Enter something";
                              }
                              return null;
                            },
                          ),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Send Password Reset Email"),
                                    content: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () async {
                                        try {
                                          await FirebaseAuth.instance
                                              .sendPasswordResetEmail(
                                                email: email.text,
                                              );
                                          Navigator.of(context).pop();
                                        } catch (e) {
                                          print(e);
                                        }
                                      },
                                      child: Text("Send Email"),
                                    ),
                                  );
                                },
                              );
                              //await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 10, bottom: 20),
                              alignment: Alignment.topRight,
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              Custombuttonauth(
                title: "Login",
                onPressed: () async {
                  if (formState.currentState!.validate()) {
                    try {
                      isLoading = true;
                      setState(() {});

                      // Sign in with email and password
                      final credential = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                        email: email.text,
                        password: password.text,
                      );

                      isLoading = false;
                      setState(() {});

                      // Check if the user's email is verified
                      if (credential.user!.emailVerified) {
                        final uid = credential.user!.uid;

                        // Fetch user document from Firestore
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .get();

                        if (userDoc.exists) {
                          final userData = userDoc.data();

                          // Read the userType field to determine the user role
                          final userType = userData?['userType'];

                          // Navigate to the appropriate home based on userType
                          if (userType == 'Company') {
                            Navigator.of(context).pushReplacementNamed("companyhome");
                          } else {
                            Navigator.of(context).pushReplacementNamed("home");
                          }
                        } else {
                          // Show error if user document not found
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("User data not found in database")),
                          );
                        }
                      } else {
                        // If email is not verified, show dialog to verify
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Email Not Verified"),
                              content: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  FirebaseAuth.instance.currentUser!
                                      .sendEmailVerification();
                                  Navigator.of(context).pop();
                                },
                                child: Text("Send Verification Email"),
                              ),
                            );
                          },
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      isLoading = false;
                      setState(() {});
                      if (e.code == 'user-not-found') {
                        print('No user found for that email.');
                      } else if (e.code == 'wrong-password') {
                        print('Wrong password provided for that user.');
                      }
                    }
                  } else {
                    print("Enter smth");
                  }
                },
              ),

                    Container(height: 20),
                    Text("OR", textAlign: TextAlign.center),
                    Container(height: 10),
                    MaterialButton(
                      height: 40,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.purple,
                      textColor: Colors.white,
                      onPressed: () {
                        signInWithGoogle();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Login"),
                          Image.asset('assets/google.png', width: 30),
                        ],
                      ),
                    ),
                    Container(height: 20),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed("signup");
                      },
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "Don't have an account ? "),
                              TextSpan(
                                text: "Register",
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
}
