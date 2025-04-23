import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
        background: Colors.purple
    )
);

ThemeData darkmode =  ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
        background: Colors.black
    )
);