import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internseek/categories/customformfieldadd.dart';
import 'package:internseek/components/custombuttonauth.dart';

class EditCategory extends StatefulWidget {
  final String docid;
  final String oldname;
  const EditCategory({super.key, required this.docid,required this.oldname});

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {

  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();

  CollectionReference categories = FirebaseFirestore.instance.collection("categories");
  bool isLoading = false;

  editCategory() async {
    if (formState.currentState!.validate()) {
      try{
        isLoading = true;
        setState(() {

        });
        await categories.doc(widget.docid).update({
          "name": name.text,
        });
      }catch(e){
        isLoading =  false;
        setState(() {

        });
        print("Error $e");
      }

      Navigator.of(context).pushReplacementNamed("homepage");//.pushNamedAndRemoveUntil("homepage", (route) => false)
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    name.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    name.text =  widget.oldname;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Category"),
      ),
      body: Form(
          key: formState,
          child: isLoading ? Center(child: CircularProgressIndicator(),) : Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 20,horizontal: 25),
                child: CustomTextFormAdd(hinttext: "Enter Name", mycontroller: name, validator: (val){
                  if(val==""){
                    return "Cant Be Empty";
                  }
                }
                ),
              ),
              Custombuttonauth(title: "Save",onPressed: (){
                editCategory();
              },)
            ],
          )),
    );
  }
}
