import 'package:flutter/material.dart';
import 'package:flutter_flip_flap/models/flip_flap_item.dart';
import 'package:flutter_flip_flap/widgets/core/back_out_curves.dart';
import 'package:flutter_flip_flap/widgets/core/flap_animator.dart';
import 'package:flutter_flip_flap/widgets/core/flap_controller_mixin.dart';
import 'package:flutter_flip_flap/widgets/core/jitter_duration_mixin.dart';
import 'package:flutter_flip_flap/widgets/core/unit_base.dart';
import 'package:flutter_flip_flap/widgets/flap/unit_tile.dart';

class FlapTextUnit extends FlapUnitBase {
  FlapTextUnit({
    super.key,
    this.unitsInPack = 1,
    required this.text,
    final List<String>? values,
    super.duration,
    super.durationJitterMs,
    this.useShortestWay = true,
    super.textStyle,
    super.unitDecoration,
    required super.unitConstraints,
    this.displayType = UnitType.mixed,
    super.enableBounce,
    super.bounceOvershoot,
  }) : values = values ?? displayType.defValues;

  final String text;
  final List<String> values;
  final UnitType displayType;
  final int unitsInPack;
  final bool useShortestWay;

  @override
  State<FlapTextUnit> createState() => _FlapTextUnitState();
}

class _FlapTextUnitState extends State<FlapTextUnit>
    with TickerProviderStateMixin, JitterDurationMixin, FlapControllerMixin {
  List<String> _values = <String>[];
  List<String> _plannedValues = <String>[];
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

    _values = widget.values;

    if (!_values.contains(targetValue)) {
      _values = List<String>.from(_values)..add(targetValue);
    }

    _currentValue = targetValue;
    _currentPlannedIndex = 0;
    _plannedValues = <String>[_currentValue];

    initFlapController(onStatus: _nextStep);
  }

  @override
  void didUpdateWidget(final FlapTextUnit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _values = widget.values;

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

      final normalizedPack = widget.unitsInPack.clamp(1, 1 << 30);
      if (normalizedPack <= 1) {
        _plannedValues = <String>[nextTarget];
        _currentValue = nextTarget;
        _currentPlannedIndex = 0;
        if (flapController.isAnimating) {
          flapController.stop();
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
      if (!flapController.isAnimating) {
        restartFlapAnimation();
      }
    }
  }

  @override
  void dispose() {
    disposeFlapController();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final nextChar = nextValue;
    final currentChar = _currentValue;
    final nextFace = UnitTile(
      text: nextChar,
      constraints: widget.unitConstraints,
      decoration: widget.unitDecoration,
      textStyle: widget.textStyle,
    );
    final currentFace = UnitTile(
      text: currentChar,
      constraints: widget.unitConstraints,
      decoration: widget.unitDecoration,
      textStyle: widget.textStyle,
    );
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: FlapAnimator(
        currentFace: currentFace,
        nextFace: nextFace,
        animation: flapAnimation,
        secondStage: flapSecondStage,
      ),
    );
  }

  void _nextStep(final AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      flapSecondStage = true;
      final secondPhaseCurve = sharedSecondPhaseCurve(
        hasChange: widget.enableBounce && nextValue == targetValue,
        overshoot: widget.bounceOvershoot,
      );
      flapAnimation = buildFlapAnimation(curve: secondPhaseCurve);
      flapController.reverse();
    }
    if (status == AnimationStatus.dismissed) {
      _currentValue = nextValue;
      _currentPlannedIndex = nextIndex;
      flapSecondStage = false;
      flapAnimation = buildFlapAnimation(curve: Curves.easeInCubic);
      if (_currentValue != targetValue) {
        restartFlapAnimation();
      }
    }
  }

  Duration get _effectiveDuration => effectiveDuration(base: widget.duration, jitterMs: widget.durationJitterMs);

  @override
  Duration get flapDuration => _effectiveDuration;

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
}
