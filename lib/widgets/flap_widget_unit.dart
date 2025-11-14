import 'dart:math';

import 'package:flutter/material.dart';

class FlapWidgetUnit extends StatefulWidget {
  const FlapWidgetUnit({
    super.key,
    required this.unitConstraints,
    required this.child,
    this.unitDecoration,
    this.duration,
    this.textStyle,
  });

  final BoxConstraints unitConstraints;
  final Decoration? unitDecoration;
  final Widget child;
  final Duration? duration;
  final TextStyle? textStyle;

  @override
  State<FlapWidgetUnit> createState() => _FlapWidgetUnitState();
}

class _FlapWidgetUnitState extends State<FlapWidgetUnit> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;
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
            duration: widget.duration ?? Duration(milliseconds: 200 + Random().nextInt(50)),
          )
          ..addStatusListener(_nextStep)
          ..addListener(() => setState(() {}));
    _animation = Tween(begin: 0, end: pi / 2).chain(CurveTween(curve: Curves.easeInCubic)).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant final FlapWidgetUnit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.child, widget.child)) {
      _nextChild = widget.child;
      if (!_controller.isAnimating) {
        _secondStage = false;
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

  void _nextStep(final AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _secondStage = true;
      final secondPhaseCurve = _nextChild.hashCode != _currentChild.hashCode
          ? FlippedCurve(_BackOutCurve(overshoot: 2.8))
          : Curves.easeInCubic;
      _animation = Tween(begin: 0, end: pi / 2).chain(CurveTween(curve: secondPhaseCurve)).animate(_controller);
      _controller.reverse();
    } else if (status == AnimationStatus.dismissed) {
      _currentChild = _nextChild;
      _secondStage = false;
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(final BuildContext context) => IntrinsicWidth(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 0.495,
                child: _UnitFace(
                  constraints: widget.unitConstraints,
                  decoration: widget.unitDecoration,
                  child: _nextChild,
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
                  child: _UnitFace(
                    constraints: widget.unitConstraints,
                    decoration: widget.unitDecoration,
                    child: _currentChild,
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(color: Theme.of(context).primaryColor, height: 0.5),
        Stack(
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: 0.495,
                child: _UnitFace(
                  constraints: widget.unitConstraints,
                  decoration: widget.unitDecoration,
                  child: _currentChild,
                ),
              ),
            ),
            Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.005)
                ..rotateX(_secondStage ? -_animation.value : pi / 2),
              child: ClipRect(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 0.495,
                  child: _UnitFace(
                    constraints: widget.unitConstraints,
                    decoration: widget.unitDecoration,
                    child: _nextChild,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
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
    child: DecoratedBox(
      decoration: decoration ?? const BoxDecoration(),
      child: child,
    ),
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
