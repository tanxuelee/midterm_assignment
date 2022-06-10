import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mytutor/views/loginscreen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MY Tutor',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        textTheme: GoogleFonts.barlowTextTheme(
          Theme.of(context).textTheme.apply(),
        ),
      ),
      home: const MySplashScreen(title: 'MY Tutor'),
    );
  }
}

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key, required String title}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  late double screenWeight, screenWidth;
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 4),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (content) => LoginScreen())));
  }

  @override
  Widget build(BuildContext context) {
    screenWeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/splash.png'),
                    fit: BoxFit.cover)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CircularProgressIndicator(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
