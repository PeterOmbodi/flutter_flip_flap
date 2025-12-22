import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_flip_flap/models/flip_flap_item.dart';
import 'package:flutter_flip_flap/widgets/core/back_out_curves.dart';
import 'package:flutter_flip_flap/widgets/core/jitter_duration_mixin.dart';

class FlipWidgetUnit extends StatefulWidget {
  const FlipWidgetUnit({
    super.key,
    required this.child,
    required this.unitConstraints,
    required this.flipAxis,
    this.flipDirection = FlipDirection.forward,
    this.unitDecoration,
    this.duration,
    this.durationJitterMs = 50,
    this.enableBounce = true,
    this.bounceOvershoot = 1.2,
  });

  final BoxConstraints unitConstraints;
  final Decoration? unitDecoration;
  final Widget child;
  final Axis flipAxis;
  final FlipDirection flipDirection;
  final Duration? duration;
  final int durationJitterMs;
  final bool enableBounce;
  final double bounceOvershoot;

  @override
  State<FlipWidgetUnit> createState() => _FlipWidgetUnitState();
}

class _FlipWidgetUnitState extends State<FlipWidgetUnit> with TickerProviderStateMixin, JitterDurationMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  late Widget _currentChild;
  late Widget _nextChild;

  @override
  void initState() {
    super.initState();
    _currentChild = widget.child;
    _nextChild = widget.child;
    _controller = AnimationController(vsync: this, duration: _effectiveDuration)
      ..addStatusListener(_handleStatus)
      ..addListener(() => setState(() {}));
    _animation = _buildAnimation();
  }

  @override
  void didUpdateWidget(covariant final FlipWidgetUnit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.child, widget.child)) {
      _nextChild = widget.child;
      if (!_controller.isAnimating) {
        _controller.duration = _effectiveDuration;
        _animation = _buildAnimation();
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _buildAnimation() => Tween<double>(begin: 0, end: 1)
      .chain(
        CurveTween(
          curve: widget.enableBounce ? BackOutCurve(overshoot: widget.bounceOvershoot) : Curves.easeInOut,
        ),
      )
      .animate(_controller);

  @override
  Widget build(final BuildContext context) {
    final angle = _animation.value * pi * _directionSign;
    final showFront = _animation.value <= 0.5;

    final front = _UnitFace(
      constraints: widget.unitConstraints,
      decoration: widget.unitDecoration,
      rotation: _rotationMatrix(angle),
      visible: showFront,
      child: _currentChild,
    );

    final back = _UnitFace(
      constraints: widget.unitConstraints,
      decoration: widget.unitDecoration,
      rotation: _rotationMatrix(angle + pi),
      visible: !showFront,
      child: _nextChild,
    );

    return Stack(alignment: Alignment.center, children: [back, front]);
  }

  Matrix4 _rotationMatrix(final double angle) => widget.flipAxis == Axis.horizontal
      ? (Matrix4.identity()..setEntry(3, 2, 0.002)..rotateY(angle))
      : (Matrix4.identity()..setEntry(3, 2, 0.002)..rotateX(angle));

  void _handleStatus(final AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _currentChild = _nextChild;
      _controller.reset();
    }
  }

  Duration get _effectiveDuration => effectiveDuration(
    base: widget.duration ?? const Duration(milliseconds: 200),
    jitterMs: widget.durationJitterMs,
  );

  double get _directionSign => widget.flipDirection == FlipDirection.backward ? -1.0 : 1.0;
}

class _UnitFace extends StatelessWidget {
  const _UnitFace({
    required this.constraints,
    required this.child,
    required this.rotation,
    required this.visible,
    this.decoration,
  });

  final BoxConstraints constraints;
  final Decoration? decoration;
  final Widget child;
  final Matrix4 rotation;
  final bool visible;

  @override
  Widget build(final BuildContext context) => Visibility(
    visible: visible,
    child: Transform(
      alignment: Alignment.center,
      transform: rotation,
      child: ConstrainedBox(
        constraints: constraints,
        child: DecoratedBox(
          decoration: decoration ?? const BoxDecoration(),
          child: child,
        ),
      ),
    ),
  );
}
