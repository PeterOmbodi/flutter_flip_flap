import 'package:flutter/animation.dart';

class FlapBackOutCurve extends Curve {
  const FlapBackOutCurve({this.overshoot = 2.5});

  final double overshoot;

  @override
  double transformInternal(double t) {
    final s = overshoot;
    t -= 1.0;
    return t * t * ((s + 1) * t + s) + 1.0;
  }
}

Curve flapSecondPhaseCurve({required final bool hasChange, final double overshoot = 2.8}) =>
    hasChange ? FlippedCurve(FlapBackOutCurve(overshoot: overshoot)) : Curves.easeInCubic;
