import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internseek/categories/edit.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List data = [];

  getData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection("categories")
            .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get();

    data = querySnapshot.docs;
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.purple;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).pushNamed("addcategory");
        },
        child: const Icon(Icons.add, size: 28),
        tooltip: 'Add Category',
      ),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Home Page"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              GoogleSignIn googleSignIn = GoogleSignIn();
              await googleSignIn.disconnect();
              await FirebaseAuth.instance.signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil("login", (route) => false);
            },
            icon: const Icon(Icons.exit_to_app),
            tooltip: "Sign Out",
          ),
        ],
        elevation: 3,
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : data.isEmpty
              ? Center(
                child: Text(
                  "No categories found.",
                  style: textTheme.titleMedium?.copyWith(color: Colors.grey),
                ),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: GridView.builder(
                  itemCount: data.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 180,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, i) {
                    final category = data[i];

                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Edit Category"),
                              content: const Text(
                                "Edit or Delete this category",
                              ),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection("categories")
                                        .doc(category.id)
                                        .delete();
                                    Navigator.of(context).pop();
                                    getData(); // Refresh data
                                  },
                                  child: const Text("Delete"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EditCategory(
                                              docid: category.id,
                                              oldname: category['name'],
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Text("Edit"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: primaryColor.withOpacity(0.3),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/folder.png",
                                height: 90,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                category["name"],
                                textAlign: TextAlign.center,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor.shade700,
                                  fontSize: 18,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
