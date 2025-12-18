import 'dart:math';

import 'package:flutter/widgets.dart';

/// Shared controller/animation boilerplate for flap units.
mixin FlapControllerMixin<T extends StatefulWidget> on State<T> implements TickerProvider {
  late AnimationController flapController;
  late Animation<double> flapAnimation;
  bool flapSecondStage = false;

  Duration get flapDuration;
  Curve get flapBaseCurve => Curves.easeInCubic;

  @protected
  void initFlapController({required final void Function(AnimationStatus) onStatus}) {
    flapController = AnimationController(vsync: this, duration: flapDuration)
      ..addStatusListener(onStatus)
      ..addListener(() => setState(() {}));
    flapAnimation = buildFlapAnimation(curve: flapBaseCurve);
  }

  @protected
  Animation<double> buildFlapAnimation({required final Curve curve}) =>
      Tween<double>(begin: 0, end: pi / 2).chain(CurveTween(curve: curve)).animate(flapController);

  @protected
  void restartFlapAnimation() {
    flapSecondStage = false;
    flapController.duration = flapDuration;
    flapAnimation = buildFlapAnimation(curve: flapBaseCurve);
    flapController.forward(from: 0);
  }

  @protected
  void disposeFlapController() {
    flapController.dispose();
  }
}
