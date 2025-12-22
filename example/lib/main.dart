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
  static final DateFormat _dayFormatter = DateFormat.EEEE();
  static final DateFormat _yearFormatter = DateFormat.y();
  static final DateFormat _dateFormatter = DateFormat('MMMM, d');
  static final DateFormat _timeFormatter = DateFormat('HH:mm:ss');
  Timer? _timer;
  DateTime _dateTime = DateTime.now();
  late String _emoji;

  @override
  void initState() {
    super.initState();
    _emoji = getRandomEmoji();
    _scheduleTick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static String _formatTime(final DateTime dt) => _timeFormatter.format(dt);

  void _scheduleTick() {
    final now = DateTime.now();
    final delay = Duration(milliseconds: 1000 - now.millisecond);
    _timer?.cancel();
    _timer = Timer(delay, () {
      if (!mounted) return;
      setState(() {
        _dateTime = DateTime.now();
        _emoji = getRandomEmoji();
      });
      _scheduleTick();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = 32.0;
    final available = (screenWidth - horizontalPadding).clamp(200.0, double.infinity);
    final formattedTime = _formatTime(_dateTime);
    final units = formattedTime.length;
    final unitWidth = (available / units).clamp(24.0, 96.0);
    final unitHeight = unitWidth * 1.7;
    final fontSize = unitHeight * 0.75;
    final unitConstraints = BoxConstraints(minWidth: unitWidth, minHeight: unitHeight, maxHeight: unitHeight);
    final widgetConstraints = unitConstraints.copyWith(minWidth: unitConstraints.minWidth * 2);
    final textStyle = FlipFlapTheme.of(context).textStyle.copyWith(fontSize: fontSize);

    final splitTime = formattedTime.split(':');
    final secondsText = splitTime.last;

    final dayName = _dayFormatter.format(_dateTime);
    final year = _yearFormatter.format(_dateTime);
    final date = _dateFormatter.format(_dateTime);

    final isOdd = _dateTime.second.isOdd;
    final accentColor = isOdd ? Colors.red : Colors.orangeAccent;
    final smallAccentTextStyle = textStyle.copyWith(color: accentColor, fontSize: fontSize / 2.3);
    final accentTextStyle = textStyle.copyWith(color: accentColor, fontSize: fontSize);
    final smallTextStyle = textStyle.copyWith(fontSize: fontSize / 2.3);

    final randomEm = _emoji;
    final labelStyle = Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding / 2),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          Text('Flap text', style: labelStyle),
          FlipFlapDisplay.fromText(text: formattedTime, textStyle: textStyle, unitConstraints: unitConstraints),
          const SizedBox(height: 12),
          Text('Flip text', style: labelStyle),
          FlipFlapDisplay.fromText(
            text: formattedTime,
            textStyle: textStyle,
            unitConstraints: unitConstraints,
            itemType: ItemType.flip,
            unitDuration: Duration(milliseconds: 400),
          ),
          const SizedBox(height: 12),
          Text('Full text without alphabet limits', style: labelStyle),
          FlipFlapDisplay.fromText(
            text: formattedTime,
            textStyle: textStyle,
            unitConstraints: unitConstraints,
            unitType: UnitType.text,
          ),
          const SizedBox(height: 12),
          Text('Flap widgets + text', style: labelStyle),
          FlipFlapDisplay(
            items: [
              FlipFlapWidgetItem.flap(
                child: Center(child: Text(randomEm, style: textStyle)),
                constraints: widgetConstraints,
              ),
              FlipFlapWidgetItem.flap(
                child: Column(
                  children: [
                    Text(isOdd ? formattedTime : date, style: smallAccentTextStyle),
                    Text(isOdd ? dayName : year, style: smallAccentTextStyle),
                  ],
                ),
                constraints: unitConstraints.copyWith(minWidth: unitConstraints.minWidth * 4),
              ),
              FlipFlapWidgetItem.flap(
                child: Center(child: Text(secondsText, style: accentTextStyle)),
                constraints: widgetConstraints,
              ),
            ],
            unitConstraints: unitConstraints,
          ),
          const SizedBox(height: 12),
          Text('Flip widgets + text', style: labelStyle),
          FlipFlapDisplay(
            items: [
              FlipFlapWidgetItem.flip(
                child: Center(child: Text(randomEm, style: textStyle)),
                constraints: widgetConstraints,
                flipAxis: Axis.horizontal,
                duration: const Duration(milliseconds: 400),
                durationJitterMs: 100,
              ),
              FlipFlapWidgetItem.flip(
                child: Column(
                  children: [
                    Text(isOdd ? formattedTime : date, style: smallAccentTextStyle),
                    Text(isOdd ? dayName : year, style: smallAccentTextStyle),
                  ],
                ),
                flipAxis: Axis.vertical,
                flipDirection: FlipDirection.backward,
                duration: const Duration(milliseconds: 400),
                constraints: unitConstraints.copyWith(minWidth: unitConstraints.minWidth * 4),
              ),
              FlipFlapWidgetItem.flip(
                child: Center(child: Text(secondsText, style: accentTextStyle)),
                flipAxis: Axis.horizontal,
                duration: const Duration(milliseconds: 300),
                durationJitterMs: 200,
                flipDirection: FlipDirection.backward,
                constraints: widgetConstraints,
              ),
            ],
            unitConstraints: unitConstraints,
          ),
          Text('Flap text + unitsInPack: 5', style: labelStyle),
          Builder(
            builder: (context) {
              final isOneEighth = (_dateTime.second ~/ 8).isOdd;
              final text = isOneEighth ? 'Time- $formattedTime' : date;
              return FlipFlapDisplay.fromText(
                text: text.padRight(text.length + (16 - text.length) ~/ 2, ' ').padLeft(16, ' '),
                textStyle: smallTextStyle,
                unitConstraints: unitConstraints.copyWith(
                  maxHeight: unitConstraints.maxHeight / 2,
                  minHeight: unitConstraints.maxHeight / 2,
                  minWidth: unitConstraints.minWidth / 2,
                  maxWidth: unitConstraints.minWidth / 2,
                ),
                unitsInPack: 5,
              );
            },
          ),
          Text('Flip text + unitsInPack: 4', style: labelStyle),
          Builder(
            builder: (context) {
              final isOneEighth = ((_dateTime.second + 4) ~/ 8).isOdd;
              final text = isOneEighth ? dayName : year;
              return FlipFlapDisplay.fromText(
                text: text.padRight(text.length + (16 - text.length) ~/ 2, ' ').padLeft(16, ' '),
                textStyle: smallTextStyle,
                itemType: ItemType.flip,
                unitConstraints: unitConstraints.copyWith(
                  maxHeight: unitConstraints.maxHeight / 2,
                  minHeight: unitConstraints.maxHeight / 2,
                  minWidth: unitConstraints.minWidth / 2,
                  maxWidth: unitConstraints.minWidth / 2,
                ),
                unitDuration: Duration(milliseconds: 600),
                unitsInPack: 4,
              );
            },
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

final Random _emojiRandom = Random();

String getRandomEmoji() {
  final range = emojiRanges[_emojiRandom.nextInt(emojiRanges.length)];
  final codePoint = range[0] + _emojiRandom.nextInt(range[1] - range[0]);
  return String.fromCharCode(codePoint);
}
