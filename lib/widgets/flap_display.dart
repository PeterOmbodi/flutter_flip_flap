import 'dart:math';


import 'package:flutter/material.dart';
import 'package:flutter_flip_flap/widgets/unit_tile.dart';

enum UnitType { character, number, special, mixed, text }

extension UnitTypeX on UnitType {
  List<String> get defValues => switch (this) {
    UnitType.character => ['', ...List<String>.generate(26, (final i) => String.fromCharCode(65 + i))],
    UnitType.number => ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
    UnitType.special => ['', '!', '@', '#', '\u007f', '%', '^', '&', '*', '(', ')', '-', '_', '=', '+'],
    UnitType.mixed => [
      '',
      ...List<String>.generate(26, (final i) => String.fromCharCode(65 + i)),
      ...['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
    ],
    UnitType.text => [],
  };
}

class FlapUnit extends StatefulWidget {
  const FlapUnit({
    super.key,
    this.cardsInPack = 1,
    required this.text,
    this.values = const [],
    this.useShortestWay = true,
    this.textStyle,
    this.unitDecoration,
    required this.unitConstraints,
    this.displayType = UnitType.mixed,
  });

  final String text;
  final List<String>? values;
  final UnitType displayType;
  final int cardsInPack;
  final bool useShortestWay;
  final TextStyle? textStyle;
  final Decoration? unitDecoration;
  final BoxConstraints unitConstraints;

  @override
  State<FlapUnit> createState() => _FlapUnitState();
}

class _FlapUnitState extends State<FlapUnit> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  List<String> _values = <String>[];
  List<String> _plannedValues = <String>[];
  bool _secondStage = false;
  String _currentValue = '';
  int _currentPlannedIndex = 0;

  String get nextValue => _plannedValues[nextIndex];

  int get nextIndex {
    final next = _currentPlannedIndex + 1;
    return next < _plannedValues.length ? next : 0;
  }

  String get targetValue => widget.text;

  @override
  void initState() {
    super.initState();

    _values = (widget.values == null || widget.values!.isEmpty) ? widget.displayType.defValues : widget.values!;

    if (!_values.contains(targetValue)) {
      _values = List<String>.from(_values)..add(targetValue);
    }

    _currentValue = targetValue;
    _currentPlannedIndex = 0;
    _plannedValues = <String>[_currentValue];

    _controller =
        AnimationController(
            vsync: this,
            duration: Duration(milliseconds: 200 + Random().nextInt(50)),
          )
          ..addStatusListener(_nextStep)
          ..addListener(() {
            setState(() {});
          });
    _animation = Tween(begin: 0, end: pi / 2).chain(CurveTween(curve: Curves.easeInCubic)).animate(_controller);
  }

  @override
  void didUpdateWidget(final FlapUnit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      final provided = widget.values;
      _values = (provided == null || provided.isEmpty) ? widget.displayType.defValues : provided;

      final prevValue = oldWidget.text;
      final nextTarget = targetValue;

      if (!_values.contains(prevValue)) {
        _values = List<String>.from(_values)..add(prevValue);
      }
      if (!_values.contains(nextTarget)) {
        _values = List<String>.from(_values)..add(nextTarget);
      }

      _currentValue = prevValue;
      _currentPlannedIndex = 0;

      final normalizedPack = widget.cardsInPack.clamp(1, 1 << 30);
      if (normalizedPack <= 1) {
        _plannedValues = <String>[nextTarget];
        _currentValue = nextTarget;
        _currentPlannedIndex = 0;
        if (_controller.isAnimating) {
          _controller.stop();
        }
        setState(() {});
        return;
      }

      _plannedValues = _planSequence(
        values: _values,
        from: prevValue,
        to: nextTarget,
        cardsInPack: widget.cardsInPack,
        useShortestWay: widget.useShortestWay,
      );
      if (!_controller.isAnimating) {
        _animation = Tween(begin: 0, end: pi / 2).chain(CurveTween(curve: Curves.easeInCubic)).animate(_controller);
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final nextChar = nextValue;
    final currentChar = _currentValue;
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.495,
                    child: UnitTile(
                      text: nextChar,
                      constraints: widget.unitConstraints,
                      decoration: widget.unitDecoration,
                      textStyle: widget.textStyle,
                    ),
                  ),
                ),
                Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..setEntry(2, 2, 0.005)
                    ..rotateX(_secondStage ? pi / 2 : _animation.value / 1),
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: 0.495,
                      child: UnitTile(
                        text: currentChar,
                        constraints: widget.unitConstraints,
                        decoration: widget.unitDecoration,
                        textStyle: widget.textStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //todo any sense to extract to theme?
            Container(color: Theme.of(context).primaryColor, height: 0.5),
            Stack(
              children: [
                ClipRect(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 0.495,
                    child: UnitTile(
                      text: currentChar,
                      constraints: widget.unitConstraints,
                      decoration: widget.unitDecoration,
                      textStyle: widget.textStyle,
                    ),
                  ),
                ),
                Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.005)
                    ..rotateX(_secondStage ? -_animation.value / 1 : pi / 2),
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: 0.495,
                      child: UnitTile(
                        text: nextChar,
                        constraints: widget.unitConstraints,
                        decoration: widget.unitDecoration,
                        textStyle: widget.textStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep(final AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _secondStage = true;
      final secondPhaseCurve = nextValue == targetValue ? FlippedCurve(_BackOutCurve(overshoot: 2.8)) : Curves.easeInCubic;
      _animation = Tween(begin: 0, end: pi / 2).chain(CurveTween(curve: secondPhaseCurve)).animate(_controller);
      _controller.reverse();
    }
    if (status == AnimationStatus.dismissed) {
      _currentValue = nextValue;
      _currentPlannedIndex = nextIndex;
      _secondStage = false;
      _animation = Tween(begin: 0, end: pi / 2).chain(CurveTween(curve: Curves.easeInCubic)).animate(_controller);
      if (_currentValue != targetValue) {
        _controller.forward();
      }
    }
  }

  List<String> _planSequence({
    required final List<String> values,
    required final String from,
    required final String to,
    required final int cardsInPack,
    required final bool useShortestWay,
  }) {
    final normalizedPack = cardsInPack.clamp(1, 1 << 30);

    if (normalizedPack <= 1 || from == to) {
      return <String>[from];
    }

    final total = values.length;
    final fromIdx = values.indexOf(from);
    final toIdx = values.indexOf(to);

    final fwdDist = (toIdx - fromIdx) % total;
    final bwdDist = (fromIdx - toIdx) % total;
    if (fwdDist == 1 || bwdDist == 1) {
      return <String>[from, to];
    }

    if (normalizedPack == 2) {
      return <String>[from, to];
    }

    List<int> _buildCircularPath({required final bool forward}) {
      final path = <int>[];
      var cursor = fromIdx;
      path.add(cursor);
      if (forward) {
        while (cursor != toIdx) {
          cursor = (cursor + 1) % total;
          path.add(cursor);
        }
      } else {
        while (cursor != toIdx) {
          cursor = (cursor - 1 + total) % total;
          path.add(cursor);
        }
      }
      return path;
    }

    final forwardDistance = fwdDist;
    final backwardDistance = bwdDist;
    bool chooseForward;
    if (useShortestWay) {
      chooseForward = forwardDistance <= backwardDistance;
    } else {
      chooseForward = forwardDistance > backwardDistance;
    }

    final path = _buildCircularPath(forward: chooseForward);

    if (normalizedPack == 3) {
      final midPathIndex = (path.length - 1) ~/ 2;
      final midIdx = path[midPathIndex];
      final mid = values[midIdx];
      return <String>[from, mid, to];
    }

    final steps = normalizedPack - 1;
    final result = <String>[];
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final pathIndex = (t * (path.length - 1)).round();
      final valueIndex = path[pathIndex];
      result.add(values[valueIndex]);
    }
    if (result.first != from) result[0] = from;
    if (result.last != to) result[result.length - 1] = to;
    return result;
  }
}

class _BackOutCurve extends Curve {
  const _BackOutCurve({this.overshoot = 2.5});

  final double overshoot;

  @override
  double transformInternal(double t) {
    // Classic backOut: t -> t-1; return t*t*((s+1)*t + s) + 1
    final s = overshoot;
    t -= 1.0;
    return t * t * ((s + 1) * t + s) + 1.0;
  }
}
