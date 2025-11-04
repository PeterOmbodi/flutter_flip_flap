import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_flip_flap/flutter_flip_flap.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) => MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(child: FlipFlapClock()),
    ),
  );
}

class FlipFlapClock extends StatefulWidget {
  const FlipFlapClock({super.key});

  @override
  State<FlipFlapClock> createState() => _FlipFlapClockState();
}

class _FlipFlapClockState extends State<FlipFlapClock> {
  Timer? _timer;
  String _time = _formatTime(DateTime.now());

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final initialDelay = Duration(milliseconds: 1000 - now.millisecond);
    _timer = Timer(initialDelay, () {
      if (!mounted) return;
      setState(() => _time = _formatTime(DateTime.now()));
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _time = _formatTime(DateTime.now()));
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static String _formatTime(final DateTime dt) {
    String two(final int n) => n < 10 ? '0$n' : '$n';
    return '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }

  @override
  Widget build(final BuildContext context) => FlipFlapDisplay(
    text: _time,
    unitConstraints: const BoxConstraints(minWidth: 24, minHeight: 40),
    displayType: UnitType.mixed,
  );
}
