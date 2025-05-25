import 'package:flutter/material.dart';

ThemeData getAdminTheme(bool isDark) {
  return isDark
      ? ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.deepOrange,
          surface: Colors.black,
        ),
      )
      : ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.red,
          secondary: Colors.deepOrange,
          surface: Colors.white,
        ),
      );
}

ThemeData getStudentTheme(bool isDark) {
  return isDark
      ? ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.green,
          secondary: Colors.lightGreen,
          surface: Colors.black,
        ),
      )
      : ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.green,
          secondary: Colors.lightGreen,
          surface: Colors.white,
        ),
      );
}

ThemeData getCompanyTheme(bool isDark) {
  return isDark
      ? ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.indigo,
          surface: Colors.black,
        ),
      )
      : ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.indigo,
          surface: Colors.white,
        ),
      );
}
