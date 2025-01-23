import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  textTheme: TextTheme(
    displayLarge: TextStyle(
        fontFamily: 'Poppins', fontSize: 40, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
        fontFamily: 'Poppins', fontSize: 34, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(
        fontFamily: 'Poppins', fontSize: 27, fontWeight: FontWeight.normal),
    headlineLarge: TextStyle(
        fontFamily: 'Poppins', fontSize: 30, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(
        fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(
        fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w500),
    titleLarge: TextStyle(
        fontFamily: 'Poppins', fontSize: 19, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(
        fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(
        fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w400),
    bodyLarge: TextStyle(
        fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(
        fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.normal),
    bodySmall: TextStyle(
        fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.normal),
    labelLarge: TextStyle(
        fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(
        fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(
        fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w400),
  ),
  colorScheme: ColorScheme.dark(
    surface: Colors.black,
    primary: Colors.grey.shade600,
    secondary: Colors.grey.shade700,
    tertiary: Colors.grey.shade900,
    inversePrimary: Colors.grey.shade300,
  ),
);
