import 'dart:math';

import 'package:flutter/material.dart';

/// Reusable layout/animation shell for a split-flap unit.
///
/// Accepts already-built faces for the "current" and "next" states and handles
/// the two-phase flip transform for top and bottom halves.
class FlapAnimator extends StatelessWidget {
  const FlapAnimator({
    super.key,
    required this.currentFace,
    required this.nextFace,
    required this.animation,
    required this.secondStage,
  });

  final Widget currentFace;
  final Widget nextFace;
  final Animation<double> animation;
  final bool secondStage;

  @override
  Widget build(final BuildContext context) => IntrinsicWidth(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            ClipRect(
              child: Align(alignment: Alignment.topCenter, heightFactor: 0.495, child: nextFace),
            ),
            Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(2, 2, 0.005)
                ..rotateX(secondStage ? pi / 2 : animation.value),
              child: ClipRect(
                child: Align(alignment: Alignment.topCenter, heightFactor: 0.495, child: currentFace),
              ),
            ),
          ],
        ),
        Container(color: Theme.of(context).primaryColor, height: 0.5),
        Stack(
          children: [
            ClipRect(
              child: Align(alignment: Alignment.bottomCenter, heightFactor: 0.495, child: currentFace),
            ),
            Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.005)
                ..rotateX(secondStage ? -animation.value : pi / 2),
              child: ClipRect(
                child: Align(alignment: Alignment.bottomCenter, heightFactor: 0.495, child: nextFace),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
