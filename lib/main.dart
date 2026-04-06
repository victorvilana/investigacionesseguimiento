import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:investigacionesseguimiento/presentation/layouts/main_layout.dart';
//import 'package:investigacionesseguimiento/presentation/screens/DashboardScreen.dart';
//import 'package:investigacionesseguimiento/presentation/screens/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:investigacionesseguimiento/presentation/screens/LoginScreen.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Firebase.initializeApp();
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;


  //FirebaseCrashlytics.instance.crash();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await analytics.logEvent(
      name: "pruebas_analiticas",
      parameters: {'timestamp': DateTime.now().toIso8601String(), 'test': 'test'}

  );


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
      home: const LoginScreen(), // Llamamos al Layout, no al Screen directamente
    );
  }
}