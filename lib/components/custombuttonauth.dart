import 'package:flutter/material.dart';

class Custombuttonauth extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  const Custombuttonauth({super.key, this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 40,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
      ),
      color: Colors.purple,
      textColor: Colors.white,
      onPressed: onPressed ,
      child: Text(title),
    );
  }
}
