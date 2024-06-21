import 'package:flutter/material.dart';
import 'dart:async';

import 'package:imageencdec/ImageEncryptionApp.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>
              ImageEncryptionApp())); // Navigate to the main app
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 67, 255, 217),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Image.asset('Images/logo.jpg', width: 190, height: 190),
            Spacer(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Developed By \n DOT',
                style: TextStyle(
                    color: Color.fromARGB(255, 232, 232, 232),
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
