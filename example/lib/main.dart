import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_flip_flap/flutter_flip_flap.dart';
import 'package:intl/intl.dart';

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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = 32.0;
    final available = (screenWidth - horizontalPadding).clamp(200.0, double.infinity);
    final units = _time.length;
    final unitWidth = (available / units).clamp(24.0, 96.0);
    final unitHeight = unitWidth * 1.7;
    final fontSize = unitHeight * 0.75;
    final unitConstraints = BoxConstraints(minWidth: unitWidth, minHeight: unitHeight, maxHeight: unitHeight);
    final widgetConstraints = unitConstraints.copyWith(minWidth: unitConstraints.minWidth * 2);
    final textStyle = FlipFlapTheme.of(context).textStyle.copyWith(fontSize: fontSize);

    final splitTime = _time.split(':');
    final hoursText = splitTime.first;
    final minutesText = splitTime[1];
    final secondsText = splitTime.last;
    final now = DateTime.now();
    final dayName = DateFormat.EEEE().format(now);
    final monthName = DateFormat.MMMM().format(now);
    final isOdd = int.parse(secondsText) % 2 == 1;
    final randomEm = getRandomEmoji();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding / 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          FlipFlapDisplay.fromText(text: _time, textStyle: textStyle, unitConstraints: unitConstraints),
          FlipFlapDisplay.fromText(
            text: _time,
            textStyle: textStyle,
            unitConstraints: unitConstraints,
            unitType: UnitType.text,
          ),
          FlipFlapDisplay(
            textStyle: textStyle,
            items: [
              FlipFlapWidgetItem(
                child: Center(child: Text(randomEm, style: textStyle)),
                constraints: widgetConstraints,
              ),
              FlipFlapWidgetItem(
                child: Column(
                  children: [
                    Text(
                      isOdd ? hoursText : monthName,
                      style: textStyle.copyWith(
                        color: isOdd ? Colors.red : Colors.orangeAccent,
                        fontSize: fontSize / 2.3,
                      ),
                    ),
                    Text(
                      isOdd ? minutesText : dayName,
                      style: textStyle.copyWith(
                        color: isOdd ? Colors.red : Colors.orangeAccent,
                        fontSize: fontSize / 2.3,
                      ),
                    ),
                  ],
                ),
                constraints: unitConstraints.copyWith(minWidth: unitConstraints.minWidth * 4),
              ),
              FlipFlapWidgetItem(
                child: Center(
                  child: Text(
                    secondsText,
                    style: textStyle.copyWith(color: isOdd ? Colors.red : Colors.orangeAccent, fontSize: fontSize),
                  ),
                ),
                constraints: widgetConstraints,
              ),
            ],
            unitConstraints: unitConstraints,
          ),
        ],
      ),
    );
  }
}

const emojiRanges = [
  [0x1F600, 0x1F64F],
  [0x1F680, 0x1F6FF],
  [0x1F300, 0x1F5FF],
  [0x1F900, 0x1F9FF],
];

String getRandomEmoji() {
  final random = Random();
  final range = emojiRanges[random.nextInt(emojiRanges.length)];
  final codePoint = range[0] + random.nextInt(range[1] - range[0]);
  return String.fromCharCode(codePoint);
}
