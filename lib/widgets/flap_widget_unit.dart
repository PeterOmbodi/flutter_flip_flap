import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_flip_flap/widgets/flap_animator.dart';
import 'package:flutter_flip_flap/widgets/jitter_duration_mixin.dart';

class FlapWidgetUnit extends StatefulWidget {
  const FlapWidgetUnit({
    super.key,
    required this.unitConstraints,
    required this.child,
    this.unitDecoration,
    this.duration = const Duration(milliseconds: 200),
    this.durationJitterMs = 50,
    this.textStyle,
  });

  final BoxConstraints unitConstraints;
  final Decoration? unitDecoration;
  final Widget child;
  final Duration duration;
  final int durationJitterMs;
  final TextStyle? textStyle;

  @override
  State<FlapWidgetUnit> createState() => _FlapWidgetUnitState();
}

class _FlapWidgetUnitState extends State<FlapWidgetUnit> with TickerProviderStateMixin, JitterDurationMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _secondStage = false;

  late Widget _currentChild;
  late Widget _nextChild;

  @override
  void initState() {
    super.initState();
    _currentChild = widget.child;
    _nextChild = widget.child;
    _controller =
        AnimationController(
            vsync: this,
            duration: _effectiveDuration,
          )
          ..addStatusListener(_nextStep)
          ..addListener(() => setState(() {}));
    _animation = Tween<double>(begin: 0, end: pi / 2).chain(CurveTween(curve: Curves.easeInCubic)).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant final FlapWidgetUnit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.child, widget.child)) {
      _nextChild = widget.child;
      if (!_controller.isAnimating) {
        _secondStage = false;
        _controller.duration = _effectiveDuration;
        _animation = Tween<double>(
          begin: 0,
          end: pi / 2,
        ).chain(CurveTween(curve: Curves.easeInCubic)).animate(_controller);
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextStep(final AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _secondStage = true;
      final secondPhaseCurve = _nextChild.hashCode != _currentChild.hashCode
          ? FlippedCurve(_BackOutCurve(overshoot: 2.8))
          : Curves.easeInCubic;
      _animation = Tween<double>(begin: 0, end: pi / 2).chain(CurveTween(curve: secondPhaseCurve)).animate(_controller);
      _controller.reverse();
    } else if (status == AnimationStatus.dismissed) {
      _currentChild = _nextChild;
      _secondStage = false;
      if (!mounted) return;
      setState(() {});
    }
  }

  Duration get _effectiveDuration => effectiveDuration(
    base: widget.duration,
    jitterMs: widget.durationJitterMs,
  );

  @override
  Widget build(final BuildContext context) => FlapAnimator(
    currentFace: _UnitFace(
      constraints: widget.unitConstraints,
      decoration: widget.unitDecoration,
      child: _currentChild,
    ),
    nextFace: _UnitFace(
      constraints: widget.unitConstraints,
      decoration: widget.unitDecoration,
      child: _nextChild,
    ),
    animation: _animation,
    secondStage: _secondStage,
  );
}

class _UnitFace extends StatelessWidget {
  const _UnitFace({required this.constraints, this.decoration, required this.child});

  final BoxConstraints constraints;
  final Decoration? decoration;
  final Widget child;

  @override
  Widget build(final BuildContext context) => ConstrainedBox(
    constraints: constraints,
    child: DecoratedBox(decoration: decoration ?? const BoxDecoration(), child: child),
  );
}

class _BackOutCurve extends Curve {
  const _BackOutCurve({this.overshoot = 2.5});

  final double overshoot;

  @override
  double transformInternal(double t) {
    final s = overshoot;
    t -= 1.0;
    return t * t * ((s + 1) * t + s) + 1.0;
  }
}
