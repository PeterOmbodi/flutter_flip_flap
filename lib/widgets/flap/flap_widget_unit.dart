import 'package:flutter/material.dart';
import 'package:flutter_flip_flap/widgets/core/back_out_curves.dart';
import 'package:flutter_flip_flap/widgets/core/flap_animator.dart';
import 'package:flutter_flip_flap/widgets/core/flap_controller_mixin.dart';
import 'package:flutter_flip_flap/widgets/core/jitter_duration_mixin.dart';

class FlapWidgetUnit extends StatefulWidget {
  const FlapWidgetUnit({
    super.key,
    required this.child,
    required this.unitConstraints,
    this.unitDecoration,
    this.duration = const Duration(milliseconds: 200),
    this.durationJitterMs = 50,
    this.textStyle,
    this.enableBounce = true,
    this.bounceOvershoot = 2.8,
  });

  final BoxConstraints unitConstraints;
  final Decoration? unitDecoration;
  final Widget child;
  final Duration duration;
  final int durationJitterMs;
  final TextStyle? textStyle;
  final bool enableBounce;
  final double bounceOvershoot;

  @override
  State<FlapWidgetUnit> createState() => _FlapWidgetUnitState();
}

class _FlapWidgetUnitState extends State<FlapWidgetUnit>
    with TickerProviderStateMixin, JitterDurationMixin, FlapControllerMixin {

  late Widget _currentChild;
  late Widget _nextChild;

  @override
  void initState() {
    super.initState();
    _currentChild = widget.child;
    _nextChild = widget.child;
    initFlapController(onStatus: _nextStep);
  }

  @override
  void didUpdateWidget(covariant final FlapWidgetUnit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.child, widget.child)) {
      _nextChild = widget.child;
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

  void _nextStep(final AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      flapSecondStage = true;
      final hasChange = _nextChild.hashCode != _currentChild.hashCode;
      final secondPhaseCurve = sharedSecondPhaseCurve(
        hasChange: widget.enableBounce && hasChange,
        overshoot: widget.bounceOvershoot,
      );
      flapAnimation = buildFlapAnimation(curve: secondPhaseCurve);
      flapController.reverse();
    } else if (status == AnimationStatus.dismissed) {
      _currentChild = _nextChild;
      flapSecondStage = false;
      if (!mounted) return;
      setState(() {});
    }
  }

  Duration get _effectiveDuration => effectiveDuration(
    base: widget.duration,
    jitterMs: widget.durationJitterMs,
  );

  @override
  Duration get flapDuration => _effectiveDuration;

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
    animation: flapAnimation,
    secondStage: flapSecondStage,
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
