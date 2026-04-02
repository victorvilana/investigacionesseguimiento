import 'package:flutter/material.dart';
import 'package:investigacionesseguimiento/presentation/layouts/main_layout.dart';
//import 'package:investigacionesseguimiento/presentation/screens/DashboardScreen.dart';
//import 'package:investigacionesseguimiento/presentation/screens/LoginScreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter', // O la que prefieras
      ),
      home: const MainLayout(), // Llamamos al Layout, no al Screen directamente
    );
  }
}