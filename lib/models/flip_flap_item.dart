import 'package:flutter/material.dart';

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
  const FlipFlapItem();
}

class FlipFlapTextItem extends FlipFlapItem {
  const FlipFlapTextItem(this.text, {this.type = UnitType.mixed, this.values, this.cardsInPack = 2});

  final String text;
  final UnitType type;
  final List<String>? values;
  final int cardsInPack;
}

class FlipFlapWidgetItem extends FlipFlapItem {
  const FlipFlapWidgetItem({this.key, required this.child, this.constraints});

  final Key? key;
  final Widget child;
  final BoxConstraints? constraints;
}
