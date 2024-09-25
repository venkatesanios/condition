import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const primaryColorDark = Color(0xFF036673);
const primaryColorMedium = Color(0xFF1D808E);
const primaryColorLight = Color(0x644BDCEF);

const textColorWhite = Colors.white;
const textColorBlack = Colors.black;
const textColorGray = Colors.grey;

final ThemeData myTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColorDark: primaryColorDark,
  primaryColor: primaryColorMedium,
  primaryColorLight: primaryColorLight,

  fontFamily: GoogleFonts.manrope().fontFamily,
  navigationRailTheme: const NavigationRailThemeData(
    backgroundColor: primaryColorDark,
    elevation: 5,
    labelType: NavigationRailLabelType.all,
    indicatorColor: primaryColorLight,
    unselectedLabelTextStyle: TextStyle(color: Colors.white),
    selectedLabelTextStyle: TextStyle(color: Colors.white),
    unselectedIconTheme: IconThemeData(color: Colors.white),
  ),
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

  // textButtonTheme: TextButtonThemeData(
  //   style: TextButton.styleFrom(
  //       foregroundColor: textColorWhite, backgroundColor: primaryColorDark
  //   ),
  // ),
);
