import 'package:flutter/material.dart';
import 'package:flutter_flip_flap/split_flap_theme.dart';
import 'package:flutter_flip_flap/widgets/flap_unit.dart';

class FlipFlapDisplay extends StatelessWidget {
  FlipFlapDisplay({
    super.key,
    required this.text,
    required this.unitConstraints,
    this.cardsInPack,
    this.textStyle,
    this.displayDecoration,
    this.displayType = UnitType.number,
    this.unitDecoration,
  }) : splitText = displayType == UnitType.text
           ? [text]
           : text.characters.toList();

  final String text;
  final int? cardsInPack;
  final TextStyle? textStyle;
  final Decoration? displayDecoration;
  final Decoration? unitDecoration;
  final BoxConstraints unitConstraints;
  final UnitType displayType;
  late final List<String> splitText;

  @override
  Widget build(final BuildContext context) {
    final theme = FlipFlapTheme.of(context);

    return DecoratedBox(
      decoration: displayDecoration ?? theme.displayDecoration,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: splitText
              .map(
                (final e) => FlapUnit(
                  text: e,
                  cardsInPack: cardsInPack ?? 1,
                  unitConstraints: unitConstraints,
                  textStyle: textStyle ?? theme.textStyle,
                  unitDecoration: unitDecoration ?? theme.unitDecoration,
                  displayType: displayType,
                  useShortestWay: false,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
