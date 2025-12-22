import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_flip_flap/models/flip_flap_item.dart';
import 'package:flutter_flip_flap/widgets/core/back_out_curves.dart';
import 'package:flutter_flip_flap/widgets/core/jitter_duration_mixin.dart';
import 'package:flutter_flip_flap/widgets/core/unit_base.dart';
import 'package:flutter_flip_flap/widgets/flap/unit_tile.dart';

class FlipTextUnit extends FlipUnitBase {
  FlipTextUnit({
    super.key,
    required this.text,
    final List<String>? values,
    this.displayType = UnitType.mixed,
    this.unitsInPack = 1,
    this.useShortestWay = true,
    super.duration,
    super.durationJitterMs,
    this.textStyle,
    super.unitDecoration,
    required super.unitConstraints,
    required super.flipAxis,
    super.flipDirection = FlipDirection.forward,
    super.enableBounce,
    super.bounceOvershoot,
  }) : values = values ?? displayType.defValues;

  final String text;
  final List<String> values;
  final UnitType displayType;
  final int unitsInPack;
  final bool useShortestWay;
  final TextStyle? textStyle;

  @override
  State<FlipTextUnit> createState() => _FlipTextUnitState();
}

class _FlipTextUnitState extends State<FlipTextUnit> with TickerProviderStateMixin, JitterDurationMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<String> _values = <String>[];
  List<String> _plannedValues = <String>[];
  String _currentValue = '';
  int _currentPlannedIndex = 0;

  String get _targetValue => widget.text;

  String get _nextValue => _plannedValues[_nextIndex];

  int get _nextIndex {
    final next = _currentPlannedIndex + 1;
    return next < _plannedValues.length ? next : 0;
  }

  @override
  void initState() {
    super.initState();
    _values = widget.values;
    if (!_values.contains(_targetValue)) {
      _values = List<String>.from(_values)..add(_targetValue);
    }

    _currentValue = _targetValue;
    _currentPlannedIndex = 0;
    _plannedValues = <String>[_currentValue];

    _controller = AnimationController(vsync: this, duration: _effectiveDuration)
      ..addStatusListener(_handleStatus)
      ..addListener(() => setState(() {}));
    _animation = _buildAnimation();
  }

  @override
  void didUpdateWidget(covariant final FlipTextUnit oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasTextChanged = oldWidget.text != widget.text;

    if (hasTextChanged) {
      _values = widget.values;

      final prevValue = oldWidget.text;
      final nextTarget = _targetValue;

      if (!_values.contains(prevValue)) {
        _values = List<String>.from(_values)..add(prevValue);
      }
      if (!_values.contains(nextTarget)) {
        _values = List<String>.from(_values)..add(nextTarget);
      }

      _currentValue = prevValue;
      _currentPlannedIndex = 0;

      final normalizedPack = widget.unitsInPack.clamp(1, 1 << 30);
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
        unitsInPack: widget.unitsInPack,
        useShortestWay: widget.useShortestWay,
      );

      _controller.duration = _effectiveDuration;
      _animation = _buildAnimation();
      _controller.stop();
      _controller.forward(from: 0);
    } else if (oldWidget.duration != widget.duration ||
        oldWidget.durationJitterMs != widget.durationJitterMs ||
        oldWidget.enableBounce != widget.enableBounce ||
        oldWidget.bounceOvershoot != widget.bounceOvershoot) {
      _controller.duration = _effectiveDuration;
      _animation = _buildAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _buildAnimation() => Tween<double>(begin: 0, end: 1)
      .chain(
        CurveTween(curve: widget.enableBounce ? BackOutCurve(overshoot: widget.bounceOvershoot) : Curves.easeInOut),
      )
      .animate(_controller);

  void _handleStatus(final AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _currentValue = _nextValue;
      _currentPlannedIndex = _nextIndex;
      _controller.reset();
      if (_currentValue != _targetValue) {
        _controller.duration = _effectiveDuration;
        _animation = _buildAnimation();
        _controller.forward(from: 0);
      } else {
        setState(() {});
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    final angle = _animation.value * pi * _directionSign;
    final showFront = _animation.value <= 0.5;

    final front = _UnitFace(
      constraints: widget.unitConstraints,
      decoration: widget.unitDecoration,
      rotation: _rotationMatrix(angle),
      visible: showFront,
      text: _currentValue,
      textStyle: widget.textStyle,
    );

    final back = _UnitFace(
      constraints: widget.unitConstraints,
      decoration: widget.unitDecoration,
      rotation: _rotationMatrix(angle + pi),
      visible: !showFront,
      text: _nextValue,
      textStyle: widget.textStyle,
    );

    return Stack(alignment: Alignment.center, children: [back, front]);
  }

  Matrix4 _rotationMatrix(final double angle) => widget.flipAxis == Axis.horizontal
      ? (Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateY(angle))
      : (Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateX(angle));

  List<String> _planSequence({
    required final List<String> values,
    required final String from,
    required final String to,
    required final int unitsInPack,
    required final bool useShortestWay,
  }) {
    final normalizedPack = unitsInPack.clamp(1, 1 << 30);

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

  Duration get _effectiveDuration => effectiveDuration(base: widget.duration, jitterMs: widget.durationJitterMs);

  double get _directionSign => widget.flipDirection == FlipDirection.backward ? -1.0 : 1.0;
}

class _UnitFace extends StatelessWidget {
  const _UnitFace({
    required this.constraints,
    required this.rotation,
    required this.visible,
    required this.text,
    this.decoration,
    this.textStyle,
  });

  final BoxConstraints constraints;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final String text;
  final Matrix4 rotation;
  final bool visible;

  @override
  Widget build(final BuildContext context) => Visibility(
    visible: visible,
    child: Transform(
      alignment: Alignment.center,
      transform: rotation,
      child: UnitTile(text: text, constraints: constraints, decoration: decoration, textStyle: textStyle),
    ),
  );
}
