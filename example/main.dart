import 'package:flutter/material.dart';
import 'package:flutter_flip_flap/flutter_flip_flap.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) => MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FlipFlapDisplay(text: '19:45', unitConstraints: BoxConstraints(minWidth: 20, minHeight: 32)),
      ),
    ),
  );
}
