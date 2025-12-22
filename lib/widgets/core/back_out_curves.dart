import 'package:flutter/animation.dart';

class BackOutCurve extends Curve {
  const BackOutCurve({this.overshoot = 2.5});

  final double overshoot;

  @override
  double transformInternal(double t) {
    final s = overshoot;
    t -= 1.0;
    return t * t * ((s + 1) * t + s) + 1.0;
  }
}

Curve sharedSecondPhaseCurve({required final bool hasChange, final double overshoot = 2.8}) =>
    hasChange ? FlippedCurve(BackOutCurve(overshoot: overshoot)) : Curves.easeInCubic;
