import 'package:flutter/material.dart';

enum ItemType { flap, flip }

enum FlipDirection { forward, backward }

enum UnitType { character, number, special, mixed, text, widget }

extension UnitTypeX on UnitType {
  List<String> get defValues => switch (this) {
    UnitType.character => ['', ...List<String>.generate(26, (final i) => String.fromCharCode(65 + i))],
    UnitType.number => const ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
    UnitType.special => const ['', '!', '@', '#', '\u007f', '%', '^', '&', '*', '(', ')', '-', '_', '=', '+'],
    UnitType.mixed => [
      '',
      ...List<String>.generate(26, (final i) => String.fromCharCode(65 + i)),
      ...['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
    ],
    UnitType.text => const [],
    UnitType.widget => const [],
  };
}

sealed class FlipFlapItem {
  const FlipFlapItem({
    this.duration,
    this.durationJitterMs,
    this.type = ItemType.flap,
    this.flipAxis,
    this.flipDirection,
  });

  final ItemType type;
  final Duration? duration;
  final int? durationJitterMs;
  final Axis? flipAxis;
  final FlipDirection? flipDirection;
}

class FlipFlapTextItem extends FlipFlapItem {
  const FlipFlapTextItem._(
    this.text, {
    this.unitType = UnitType.mixed,
    this.values,
    this.unitsInPack = 2,
    required super.type,
    super.flipAxis,
    super.flipDirection,
    super.duration,
    super.durationJitterMs,
  });

  factory FlipFlapTextItem.flap(
    final String text, {
    final UnitType unitType = UnitType.mixed,
    final List<String>? values,
    final int unitsInPack = 2,
    final Duration? duration,
    final int? durationJitterMs,
  }) => FlipFlapTextItem._(
    text,
    unitType: unitType,
    values: values,
    unitsInPack: unitsInPack,
    type: ItemType.flap,
    duration: duration,
    durationJitterMs: durationJitterMs,
  );

  factory FlipFlapTextItem.flip(
    final String text, {
    final UnitType unitType = UnitType.mixed,
    final List<String>? values,
    final int unitsInPack = 2,
    required final Axis flipAxis,
    final FlipDirection flipDirection = FlipDirection.forward,
    final Duration? duration,
    final int? durationJitterMs,
  }) => FlipFlapTextItem._(
    text,
    unitType: unitType,
    values: values,
    unitsInPack: unitsInPack,
    type: ItemType.flip,
    flipAxis: flipAxis,
    flipDirection: flipDirection,
    duration: duration,
    durationJitterMs: durationJitterMs,
  );

  final String text;
  final UnitType unitType;
  final List<String>? values;
  final int unitsInPack;
}

class FlipFlapWidgetItem extends FlipFlapItem {
  const FlipFlapWidgetItem._({
    this.key,
    required this.child,
    this.constraints,
    required super.type,
    super.flipAxis,
    super.flipDirection,
    super.duration,
    super.durationJitterMs,
  });

  factory FlipFlapWidgetItem.flap({
    final Key? key,
    required final Widget child,
    final BoxConstraints? constraints,
    final Duration? duration,
    final int? durationJitterMs,
  }) => FlipFlapWidgetItem._(
    key: key,
    child: child,
    constraints: constraints,
    type: ItemType.flap,
    duration: duration,
    durationJitterMs: durationJitterMs,
  );

  factory FlipFlapWidgetItem.flip({
    final Key? key,
    required final Widget child,
    final BoxConstraints? constraints,
    required final Axis flipAxis,
    final FlipDirection flipDirection = FlipDirection.forward,
    final Duration? duration,
    final int? durationJitterMs,
  }) => FlipFlapWidgetItem._(
    key: key,
    child: child,
    constraints: constraints,
    type: ItemType.flip,
    flipAxis: flipAxis,
    flipDirection: flipDirection,
    duration: duration,
    durationJitterMs: durationJitterMs,
  );

  final Key? key;
  final Widget child;
  final BoxConstraints? constraints;
}
