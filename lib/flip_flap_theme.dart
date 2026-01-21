import 'package:flutter/material.dart';

@immutable
class FlipFlapTheme extends ThemeExtension<FlipFlapTheme> {
  const FlipFlapTheme({required this.unitDecoration, required this.displayDecoration, required this.textStyle});

  final BoxDecoration unitDecoration;
  final BoxDecoration displayDecoration;
  final TextStyle textStyle;

  @override
  FlipFlapTheme copyWith({
    final BoxDecoration? tileDecoration,
    final BoxDecoration? panelDecoration,
    final TextStyle? symbolStyle,
  }) => FlipFlapTheme(
    unitDecoration: tileDecoration ?? unitDecoration,
    displayDecoration: panelDecoration ?? displayDecoration,
    textStyle: symbolStyle ?? textStyle,
  );

  @override
  FlipFlapTheme lerp(final ThemeExtension<FlipFlapTheme>? other, final double t) {
    if (other is! FlipFlapTheme) return this;

    return FlipFlapTheme(
      unitDecoration: BoxDecoration.lerp(unitDecoration, other.unitDecoration, t) ?? unitDecoration,
      displayDecoration: BoxDecoration.lerp(displayDecoration, other.displayDecoration, t) ?? displayDecoration,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t) ?? textStyle,
    );
  }

  static FlipFlapTheme of(final BuildContext context) {
    final fromTheme = Theme.of(context).extension<FlipFlapTheme>();
    if (fromTheme != null) return fromTheme;
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? FlipFlapTheme.dark : FlipFlapTheme.light;
  }

  static final FlipFlapTheme light = FlipFlapTheme(
    unitDecoration: const BoxDecoration(
      color: Color(0xFFE0E0E0),
      border: Border.fromBorderSide(BorderSide(color: Color(0xFF424242), width: 0.5)),
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
    displayDecoration: const BoxDecoration(color: Colors.transparent),
    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87),
  );

  static final FlipFlapTheme dark = FlipFlapTheme(
    unitDecoration: const BoxDecoration(
      color: Color(0xFF424242),
      border: Border.fromBorderSide(BorderSide(color: Color(0xFFFFFFFF), width: 0.5)),
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
    displayDecoration: const BoxDecoration(color: Colors.transparent),
    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white70),
  );
}
