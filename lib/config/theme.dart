import 'package:flutter/material.dart';

     const bleuCoris = Color(0xFF002B6B);
     const rougeCoris = Color.fromARGB(255, 242, 4, 4);

     final appTheme = ThemeData(
       primaryColor: bleuCoris,
       scaffoldBackgroundColor: Colors.grey[100],
       fontFamily: 'Roboto',
       elevatedButtonTheme: ElevatedButtonThemeData(
         style: ElevatedButton.styleFrom(
           backgroundColor: bleuCoris,
           foregroundColor: Colors.white,
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(10),
           ),
         ),
       ),
       textButtonTheme: TextButtonThemeData(
         style: TextButton.styleFrom(
           foregroundColor: rougeCoris,
         ),
       ),
       inputDecorationTheme: const InputDecorationTheme(
         border: OutlineInputBorder(
           borderRadius: BorderRadius.all(Radius.circular(8)),
         ),
         focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.all(Radius.circular(8)),
           borderSide: BorderSide(color: bleuCoris, width: 2),
         ),
         errorBorder: OutlineInputBorder(
           borderRadius: BorderRadius.all(Radius.circular(8)),
           borderSide: BorderSide(color: rougeCoris, width: 2),
         ),
       ),
     );