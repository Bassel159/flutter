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

  List data = [] ;

  getData() async{

    QuerySnapshot  querySnapshot = await FirebaseFirestore.instance.collection("categories").where("id",isEqualTo: FirebaseAuth.instance.currentUser!.uid ).get();
    data.addAll(querySnapshot.docs);
    isLoading = false;
    setState(() {

    });

  }

  @override
  void initState(){
    getData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,foregroundColor: Colors.white,
        onPressed: (){
          Navigator.of(context).pushNamed("addcategory");
        },
        child: Icon(Icons.add),),
      appBar: AppBar(
        title: const Text("HomePage"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () async {
            GoogleSignIn googleSignIn = GoogleSignIn();
            googleSignIn.disconnect();
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushNamedAndRemoveUntil("login", (route) => false);
          }, icon: Icon(Icons.exit_to_app))
        ],
      ),
      body:isLoading == true ? Center(child: CircularProgressIndicator(),) : GridView.builder(
          itemCount: data.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,mainAxisExtent: 160),
          itemBuilder: (context,i) {
            return InkWell(
              onLongPress: (){
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Edit Category"),
                      content: Text("Edit or Delete this category"),
                      actions: [ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple,foregroundColor: Colors.white),
                        onPressed: () async{
                          await FirebaseFirestore.instance.collection("categories").doc(data[i].id).delete();
                          Navigator.of(context).pushReplacementNamed("homepage");
                        },
                        child: Text("Delete"),
                      ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple,foregroundColor: Colors.white),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditCategory(docid: data[i].id, oldname: data[i]['name']) ));
                          },
                          child: Text("Edit"),
                        )],
                    );
                  },
                );
              },
              child: Card(child:
              Container(
                padding: EdgeInsets.all(10),
                child: Column(children: [
                  Image.asset("assets/folder.png", height: 100,),
                  Text(data[i]["name"]),

                ],),
              ),),
            );
          }

      ),
    );
  }
}
