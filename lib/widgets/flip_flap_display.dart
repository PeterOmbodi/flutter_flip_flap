import 'package:flutter/material.dart';
import 'package:flutter_flip_flap/models/flip_flap_item.dart';
import 'package:flutter_flip_flap/split_flap_theme.dart';
import 'package:flutter_flip_flap/widgets/flap_text_unit.dart';
import 'package:flutter_flip_flap/widgets/flap_widget_unit.dart';

class FlipFlapDisplay extends StatelessWidget {
  const FlipFlapDisplay({
    super.key,
    required this.items,
    required this.unitConstraints,
    this.textStyle,
    this.displayDecoration,
    this.unitDecoration,
  });

  factory FlipFlapDisplay.fromText({
    final Key? key,
    required final String text,
    required final BoxConstraints unitConstraints,
    final TextStyle? textStyle,
    final Decoration? displayDecoration,
    final Decoration? unitDecoration,
    final UnitType unitType = UnitType.mixed,
    final int cardsInPack = 2,
  }) {
    final chars = unitType == UnitType.text ? <String>[text] : text.characters.toList();
    final items = chars.map((final e) => FlipFlapTextItem(e, type: unitType, cardsInPack: cardsInPack)).toList();
    return FlipFlapDisplay(
      key: key,
      items: items,
      unitConstraints: unitConstraints,
      textStyle: textStyle,
      displayDecoration: displayDecoration,
      unitDecoration: unitDecoration,
    );
  }

  //
  // factory FlapDisplay.mapped({
  //   final Key? key,
  //   required final String text,
  //   required final FlipFlapTextItem Function(int index, String char) mapper,
  //   required final BoxConstraints unitConstraints,
  //   final TextStyle? textStyle,
  //   final Decoration? displayDecoration,
  //   final Decoration? unitDecoration,
  // }) {
  //   final chars = text.characters.toList();
  //   final items = <FlipFlapItem>[for (int i = 0; i < chars.length; i++) mapper(i, chars[i])];
  //   return FlapDisplay(
  //     key: key,
  //     items: items,
  //     unitConstraints: unitConstraints,
  //     textStyle: textStyle,
  //     displayDecoration: displayDecoration,
  //     unitDecoration: unitDecoration,
  //   );
  // }

  final List<FlipFlapItem> items;
  final TextStyle? textStyle;
  final Decoration? displayDecoration;
  final Decoration? unitDecoration;
  final BoxConstraints unitConstraints;

  @override
  Widget build(final BuildContext context) {
    final theme = FlipFlapTheme.of(context);
    return DecoratedBox(
      decoration: displayDecoration ?? theme.displayDecoration,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < items.length; i++)
              switch (items[i]) {
                FlipFlapTextItem(:final text, :final type, :final values, :final cardsInPack) => FlapTextUnit(
                  key: Key('ff-text-$i-$key'),
                  text: text,
                  values: values,
                  displayType: type,
                  cardsInPack: cardsInPack,
                  unitConstraints: unitConstraints,
                  textStyle: textStyle ?? theme.textStyle,
                  unitDecoration: unitDecoration ?? theme.unitDecoration,
                  useShortestWay: false,
                ),
                FlipFlapWidgetItem(:final key, :final child, :final constraints) => FlapWidgetUnit(
                  key: key ?? child.key,
                  unitConstraints: constraints ?? unitConstraints,
                  unitDecoration: unitDecoration ?? theme.unitDecoration,
                  child: child,
                ),
              },
          ],
        ),
      ),
    );
  }
}
