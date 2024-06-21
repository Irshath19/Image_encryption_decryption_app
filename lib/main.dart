import 'package:flutter/material.dart';
import 'package:imageencdec/ImageEncryptionApp.dart';
import 'package:imageencdec/Imdenc.dart';
import 'package:imageencdec/SplashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image ecrypt decrypt',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ImagePickerAndEncrypt(),
    );
  }
}
