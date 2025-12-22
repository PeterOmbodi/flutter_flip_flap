import 'package:flutter/material.dart';
import 'package:flutter_flip_flap/models/flip_flap_item.dart';

/// Shared configuration for flap-based units (two-phase mechanical animation).
abstract class FlapUnitBase extends StatefulWidget {
  const FlapUnitBase({
    super.key,
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
  final Duration duration;
  final int durationJitterMs;
  final TextStyle? textStyle;
  final bool enableBounce;
  final double bounceOvershoot;
}

/// Shared configuration for flip-based units (3D flip animation).
abstract class FlipUnitBase extends StatefulWidget {
  const FlipUnitBase({
    super.key,
    required this.unitConstraints,
    required this.flipAxis,
    this.flipDirection = FlipDirection.forward,
    this.unitDecoration,
    this.duration = const Duration(milliseconds: 400),
    this.durationJitterMs = 50,
    this.enableBounce = true,
    this.bounceOvershoot = 1.2,
  });

  final BoxConstraints unitConstraints;
  final Decoration? unitDecoration;
  final Axis flipAxis;
  final FlipDirection flipDirection;
  final Duration duration;
  final int durationJitterMs;
  final bool enableBounce;
  final double bounceOvershoot;
}
