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
  static const double _horizontalPadding = 32.0;
  static const double _minUnitWidth = 24.0;
  static const double _maxUnitWidth = 96.0;
  static const double _unitHeightFactor = 1.7;
  static const double _fontSizeFactor = 0.75;
  static const double _smallFontSizeFactor = 2.3;
  static const int _packedTextWidth = 16;
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

  static String _padToWidth(final String text) =>
      text.padRight(text.length + (_packedTextWidth - text.length) ~/ 2, ' ').padLeft(_packedTextWidth, ' ');

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
    final layout = _buildLayout(context);
    final time = _buildTimeModel(_dateTime, _emoji);
    final labelStyle = Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70);
    final accentColor = time.isQuarterTick ? Colors.red : Colors.orangeAccent;
    final smallAccentTextStyle = layout.textStyle.copyWith(
      color: accentColor,
      fontSize: layout.textStyle.fontSize! / _smallFontSizeFactor,
    );
    final accentTextStyle = layout.textStyle.copyWith(color: accentColor);
    final wideConstraints = layout.unitConstraints.copyWith(minWidth: layout.unitConstraints.minWidth * 4);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding / 2),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          Text('Flap text', style: labelStyle),
          FlipFlapDisplay.fromText(
            text: time.formattedTime,
            textStyle: layout.textStyle,
            unitConstraints: layout.unitConstraints,
          ),
          const SizedBox(height: 12),
          Text('Flip text', style: labelStyle),
          FlipFlapDisplay.fromText(
            text: time.formattedTime,
            textStyle: layout.textStyle,
            unitConstraints: layout.unitConstraints,
            itemType: ItemType.flip,
            unitDuration: const Duration(milliseconds: 400),
          ),
          const SizedBox(height: 12),
          Text('Full text without alphabet limits', style: labelStyle),
          FlipFlapDisplay.fromText(
            text: time.formattedTime,
            textStyle: layout.textStyle,
            unitConstraints: layout.unitConstraints,
            unitType: UnitType.text,
          ),
          const SizedBox(height: 12),
          Text('Flap widgets + text', style: labelStyle),
          FlipFlapDisplay(
            items: [
              FlipFlapWidgetItem.flap(
                child: Center(child: Text(time.emoji, style: layout.textStyle)),
                constraints: layout.widgetConstraints,
              ),
              FlipFlapWidgetItem.flap(
                child: Column(
                  children: [
                    Text(time.isQuarterTick ? time.formattedTime : time.date, style: smallAccentTextStyle),
                    Text(time.isQuarterTick ? time.dayName : time.year, style: smallAccentTextStyle),
                  ],
                ),
                constraints: wideConstraints,
                animationTrigger: ValueKey('flap:${time.isQuarterTick ? time.dayName : time.year}'),
              ),
              FlipFlapWidgetItem.flap(
                child: Center(child: Text(time.secondsText, style: accentTextStyle)),
                constraints: layout.widgetConstraints,
              ),
            ],
            unitConstraints: layout.unitConstraints,
          ),
          const SizedBox(height: 12),
          Text('Flip widgets + text', style: labelStyle),
          FlipFlapDisplay(
            items: [
              FlipFlapWidgetItem.flip(
                child: Center(child: Text(time.emoji, style: layout.textStyle)),
                constraints: layout.widgetConstraints,
                flipAxis: Axis.horizontal,
                flipDirection: time.isOdd ? FlipDirection.forward : FlipDirection.backward,
                durationJitterMs: 100,
              ),
              FlipFlapWidgetItem.flip(
                child: Column(
                  children: [
                    Text(time.isQuarterTick ? time.formattedTime : time.date, style: smallAccentTextStyle),
                    Text(time.isQuarterTick ? time.dayName : time.year, style: smallAccentTextStyle),
                  ],
                ),
                constraints: wideConstraints,
                flipAxis: Axis.vertical,
                flipDirection: FlipDirection.backward,
                animationTrigger: ValueKey('flip:${time.isQuarterTick ? time.dayName : time.year}'),
                duration: const Duration(milliseconds: 1200),
              ),
              FlipFlapWidgetItem.flip(
                child: Center(child: Text(time.secondsText, style: accentTextStyle)),
                flipAxis: Axis.horizontal,
                durationJitterMs: 200,
                flipDirection: FlipDirection.backward,
                constraints: layout.widgetConstraints,
              ),
            ],
            unitConstraints: layout.unitConstraints,
          ),
          Text('Flap text + unitsInPack: 5', style: labelStyle),
          Builder(
            builder: (context) {
              final text = time.isEighthTick ? 'Time- ${time.formattedTime}' : time.date;
              return FlipFlapDisplay.fromText(
                text: _padToWidth(text),
                textStyle: layout.smallTextStyle,
                unitConstraints: _smallUnitConstraints(layout.unitConstraints),
                unitsInPack: 5,
              );
            },
          ),
          Text('Flip text + unitsInPack: 4', style: labelStyle),
          Builder(
            builder: (context) {
              final text = time.isEighthTick ? time.dayName : time.year;
              return FlipFlapDisplay.fromText(
                text: _padToWidth(text),
                textStyle: layout.smallTextStyle,
                itemType: ItemType.flip,
                unitConstraints: _smallUnitConstraints(layout.unitConstraints),
                unitDuration: const Duration(milliseconds: 600),
                unitsInPack: 4,
              );
            },
          ),
        ],
      ),
    );
  }

  _ClockLayout _buildLayout(final BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final available = (screenWidth - _horizontalPadding).clamp(200.0, double.infinity);
    final formattedTime = _formatTime(_dateTime);
    final units = formattedTime.length;
    final unitWidth = (available / units).clamp(_minUnitWidth, _maxUnitWidth);
    final unitHeight = unitWidth * _unitHeightFactor;
    final fontSize = unitHeight * _fontSizeFactor;
    final unitConstraints = BoxConstraints(minWidth: unitWidth, minHeight: unitHeight, maxHeight: unitHeight);
    final widgetConstraints = unitConstraints.copyWith(minWidth: unitConstraints.minWidth * 2);
    final textStyle = FlipFlapTheme.of(context).textStyle.copyWith(fontSize: fontSize);
    final smallTextStyle = textStyle.copyWith(fontSize: fontSize / _smallFontSizeFactor);
    return _ClockLayout(
      unitConstraints: unitConstraints,
      widgetConstraints: widgetConstraints,
      textStyle: textStyle,
      smallTextStyle: smallTextStyle,
    );
  }

  _ClockTime _buildTimeModel(final DateTime now, final String emoji) {
    final formattedTime = _formatTime(now);
    final splitTime = formattedTime.split(':');
    final secondsText = splitTime.last;
    final dayName = _dayFormatter.format(now);
    final year = _yearFormatter.format(now);
    final date = _dateFormatter.format(now);
    final seconds = (now.millisecondsSinceEpoch / 1000).ceil();
    final isOdd = now.second.isOdd;
    final isQuarterTick = ((seconds + 2) ~/ 4).isOdd;
    final isEighthTick = ((seconds + 4) ~/ 8).isOdd;
    return _ClockTime(
      formattedTime: formattedTime,
      secondsText: secondsText,
      dayName: dayName,
      year: year,
      date: date,
      emoji: emoji,
      isOdd: isOdd,
      isQuarterTick: isQuarterTick,
      isEighthTick: isEighthTick,
    );
  }

  BoxConstraints _smallUnitConstraints(final BoxConstraints base) => base.copyWith(
    maxHeight: base.maxHeight / 2,
    minHeight: base.maxHeight / 2,
    minWidth: base.minWidth / 2,
    maxWidth: base.minWidth / 2,
  );
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

class _ClockLayout {
  const _ClockLayout({
    required this.unitConstraints,
    required this.widgetConstraints,
    required this.textStyle,
    required this.smallTextStyle,
  });

  final BoxConstraints unitConstraints;
  final BoxConstraints widgetConstraints;
  final TextStyle textStyle;
  final TextStyle smallTextStyle;
}

class _ClockTime {
  const _ClockTime({
    required this.formattedTime,
    required this.secondsText,
    required this.dayName,
    required this.year,
    required this.date,
    required this.emoji,
    required this.isOdd,
    required this.isQuarterTick,
    required this.isEighthTick,
  });

  final String formattedTime;
  final String secondsText;
  final String dayName;
  final String year;
  final String date;
  final String emoji;
  final bool isOdd;
  final bool isQuarterTick;
  final bool isEighthTick;
}
