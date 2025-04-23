import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: Colors.deepPurple,
    secondary: Colors.blueGrey,
  ),
);

ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.black,
    primary: Colors.cyan,
    secondary: Colors.blueGrey,
  ),
);
