import 'package:flutter/material.dart';
//import 'package:myapp/ProfileScreen.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "",
          style: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Complete Profile",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8 ),
                  const Text(
                    "Fill in your personal information",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  const ComplateProfileForm(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

class ComplateProfileForm extends StatelessWidget {
  const ComplateProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            onSaved: (firstName) {},
            onChanged: (firstName) {},
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Enter your first name",
              labelText: "First Name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              suffixIcon: const Icon(Icons.person_outline, color: Color(0xFF757575)),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color.fromARGB(255, 67, 111, 255)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: TextFormField(
              onSaved: (lastName) {},
              onChanged: (lastName) {},
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: "Enter your last name",
                labelText: "Last Name",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: const TextStyle(color: Color(0xFF757575)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                suffixIcon: const Icon(Icons.person_outline, color: Color(0xFF757575)),
                border: authOutlineInputBorder,
                enabledBorder: authOutlineInputBorder,
                focusedBorder: authOutlineInputBorder.copyWith(
                  borderSide: const BorderSide(color: Color.fromARGB(255, 67, 111, 255)),
                ),
              ),
            ),
          ),
          TextFormField(
            onSaved: (phone) {},
            onChanged: (phone) {},
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: "Enter your phone number",
              labelText: "Phone Number",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              suffixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF757575)),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color.fromARGB(255, 67, 111, 255)),
              ),
            ),
          ),
          const SizedBox(height: 30),
          FloatingActionButton.extended(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.image_outlined, size: 60, color: Color.fromARGB(255, 24, 11, 11)),
                      SizedBox(height: 20),
                      Text("CV uploaded successfully!"),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
            label: const Text("Upload CV"),
            icon: const Icon(Icons.upload_file),
            backgroundColor: Color.fromARGB(255, 57, 55, 54),
            foregroundColor: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(36),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () { /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );*/},
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Color.fromARGB(255, 22, 6, 131),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            child: const Text("Continue"),
          )
        ],
      ),
    );
  }
}