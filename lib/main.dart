import 'package:flutter/material.dart';
import 'package:walet_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'owner_page.dart';
import 'manager_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final savedUsername = prefs.getString('username');
  final savedRole = prefs.getString('role');

  Widget _defaultHome = const LoginPage();

  if (savedUsername != null && savedRole != null) {
    if (savedRole == 'owner') {
      _defaultHome = const OwnerPage();
    } else if (savedRole == 'manager') {
      _defaultHome = ManagerPage(username: savedUsername);
    }
  }

  runApp(MyApp(defaultHome: _defaultHome));
}

class MyApp extends StatelessWidget {
  final Widget defaultHome;
  const MyApp({super.key, required this.defaultHome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Walet App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: defaultHome,
    );
  }
}
