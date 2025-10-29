import 'package:flutter/material.dart';
import 'package:mycorislife/config/routes.dart';
import 'package:mycorislife/config/theme.dart';



void main() {
  runApp(const MyCorisLifeApp());
  
}

class MyCorisLifeApp extends StatelessWidget {
  const MyCorisLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyCorisLife',
      theme: appTheme, 
      initialRoute: '/login', 
      routes: appRoutes, 
      debugShowCheckedModeBanner: false,
    );
  }
}