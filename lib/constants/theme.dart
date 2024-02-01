import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const primaryColorDark = Color(0xFF0D5D9A);
const primaryColorMedium = Color(0xFF9EBED7);
const primaryColorLight = Color(0xFFDAE7F3);

const secondaryColorDark = Color(0xFFFFB402);
const secondaryColorMedium = Color(0xFFFFD44C);
const secondaryColorLight = Color(0xFFEEDFB1);

const textColorWhite = Colors.white;
const textColorBlack = Colors.black;
const textColorGray = Colors.grey;

final ThemeData myTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: primaryColorDark,
  fontFamily: GoogleFonts.poppins().fontFamily,

  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColorDark,
    titleTextStyle: TextStyle(color: textColorWhite, fontSize: 22),
    iconTheme: IconThemeData(
      color: Colors.white, // Set your desired color here
    ),
  ),

  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 22, color: textColorBlack),
    titleMedium: TextStyle(fontSize: 15, color: textColorBlack),
    titleSmall: TextStyle(fontSize: 12, color: textColorBlack),
    bodyMedium : TextStyle(fontSize: 13, color: textColorBlack, fontWeight: FontWeight.bold),
    bodySmall : TextStyle(fontSize: 12, color: textColorBlack, fontWeight: FontWeight.bold),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: textColorWhite, backgroundColor: primaryColorDark
    ),
  ),


);



