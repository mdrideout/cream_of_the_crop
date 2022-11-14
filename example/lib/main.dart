import 'package:flutter/material.dart';

import 'crop_resize_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      supportedLocales: [
        Locale('en', 'US'),
      ],
      locale: Locale('en', 'US'),
      home: CropResizeScreen(),
    );
  }
}
