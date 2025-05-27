import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  Future<void> signInWithGoogle() async {
    try {
      // Start Google sign-in flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If user cancels the sign-in
      if (googleUser == null) return;

      // Retrieve Google auth tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential with Google tokens
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using the credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user == null) return;

      final uid = user.uid;

      // Check Firestore for existing user document
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // ✅ Existing user: go to home screen
        Navigator.of(context).pushReplacementNamed("home");
      } else {
        // 🆕 New user: create a minimal user record if needed
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': user.email,
          'studentName': user.displayName,
          // You can add more fields here if required later
        });

        // 🚪 Route to enter info screen
        Navigator.of(context).pushReplacementNamed("enterinfo");
      }
    } catch (e) {
      print("Google sign-in error: $e");

      // Show an error message to the user if something goes wrong
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error during Google sign-in")));
    }
  }

  @override
  void dispose() {
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: email,
                            validator: (val) {
                              if (val == "") {
                                return "Enter something";
                              }
                              return null;
                            },
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: "Enter your Email",
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).hintColor,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 20,
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(
                                    context,
                                  ).inputDecorationTheme.fillColor ??
                                  Theme.of(context).cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),
                          Text(
                            "Password",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: password,
                            validator: (val) {
                              if (val == "") {
                                return "Enter something";
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Enter your Password",
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).hintColor,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 20,
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(
                                    context,
                                  ).inputDecorationTheme.fillColor ??
                                  Theme.of(context).cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
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

                            final credential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                  email: email.text,
                                  password: password.text,
                                );

                            isLoading = false;
                            setState(() {});

                            if (credential.user!.emailVerified) {
                              final uid = credential.user!.uid;
                              final userDoc =
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .get();

                              if (userDoc.exists) {
                                final userData = userDoc.data();
                                final userType = userData?['userType'];
                                final isApproved =
                                    userData?['isApproved'] ?? false;

                                if (userType == 'Company') {
                                  if (isApproved) {
                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed("companyhome");
                                  } else {
                                    // Show alert that the company is not approved yet
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Approval Pending"),
                                          content: Text(
                                            "Your company account is pending approval from the admin. Please wait for approval to access the system.",
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                } else if (userType == 'Admin') {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed("adminhome");
                                } else {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed("home");
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("User data not found"),
                                  ),
                                );
                              }
                            } else {
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
                            print(e.message);
                          }
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
