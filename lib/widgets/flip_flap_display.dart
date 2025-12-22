import 'package:flutter/material.dart';
import 'package:flutter_flip_flap/models/flip_flap_item.dart';
import 'package:flutter_flip_flap/split_flap_theme.dart';
import 'package:flutter_flip_flap/widgets/flap/flap_text_unit.dart';
import 'package:flutter_flip_flap/widgets/flap/flap_widget_unit.dart';
import 'package:flutter_flip_flap/widgets/flip/flip_text_unit.dart';
import 'package:flutter_flip_flap/widgets/flip/flip_widget_unit.dart';

class FlipFlapDisplay extends StatelessWidget {
  const FlipFlapDisplay({
    super.key,
    required this.items,
    required this.unitConstraints,
    this.useShortestWay = true,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.unitDuration,
    this.unitDurationJitterMs,
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
    final int unitsInPack = 2,
    final ItemType itemType = ItemType.flap,
    final bool useShortestWay = true,
    final Duration? unitDuration,
    final int? unitDurationJitterMs,
  }) => FlipFlapDisplay(
    key: key,
    items: _itemsFromText(
      text: text,
      unitType: unitType,
      unitsInPack: unitsInPack,
      duration: unitDuration,
      durationJitterMs: unitDurationJitterMs,
      itemType: itemType,
    ),
    unitConstraints: unitConstraints,
    textStyle: textStyle,
    displayDecoration: displayDecoration,
    unitDecoration: unitDecoration,
    useShortestWay: useShortestWay,
    unitDuration: unitDuration,
    unitDurationJitterMs: unitDurationJitterMs,
  );

  final List<FlipFlapItem> items;
  final bool useShortestWay;
  final MainAxisAlignment mainAxisAlignment;
  final Duration? unitDuration;
  final int? unitDurationJitterMs;
  final TextStyle? textStyle;
  final Decoration? displayDecoration;
  final Decoration? unitDecoration;
  final BoxConstraints unitConstraints;

  @override
  Widget build(final BuildContext context) {
    final theme = FlipFlapTheme.of(context);
    return DecoratedBox(
      decoration: displayDecoration ?? theme.displayDecoration,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          for (int i = 0; i < items.length; i++) _buildUnit(items[i], theme, i),
        ],
      ),
    );
  }

  Widget _buildUnit(
    final FlipFlapItem item,
    final FlipFlapTheme theme,
    final int index,
  ) => switch (item) {
    FlipFlapTextItem(
      :final text,
      :final unitType,
      :final values,
      :final unitsInPack,
      :final type,
    ) =>
      switch (type) {
        ItemType.flap => FlapTextUnit(
          key: Key('ff-text-$index-$key'),
          text: text,
          values: values,
          displayType: unitType,
          unitsInPack: unitsInPack,
          duration: _resolveDuration(item.duration),
          durationJitterMs: _resolveJitter(item.durationJitterMs),
          unitConstraints: unitConstraints,
          textStyle: textStyle ?? theme.textStyle,
          unitDecoration: unitDecoration ?? theme.unitDecoration,
          useShortestWay: useShortestWay,
        ),
        ItemType.flip => FlipTextUnit(
          key: Key('ff-text-$index-$key'),
          text: text,
          values: values,
          displayType: unitType,
          unitsInPack: unitsInPack,
          duration: _resolveDuration(item.duration),
          durationJitterMs: _resolveJitter(item.durationJitterMs),
          unitConstraints: unitConstraints,
          textStyle: textStyle ?? theme.textStyle,
          unitDecoration: unitDecoration ?? theme.unitDecoration,
          useShortestWay: useShortestWay,
          flipAxis: item.flipAxis ?? Axis.horizontal,
          flipDirection: item.flipDirection ?? FlipDirection.forward,
        ),
      },
    FlipFlapWidgetItem(
      :final key,
      :final child,
      :final constraints,
      :final type,
    ) =>
      switch (type) {
        ItemType.flap => FlapWidgetUnit(
          key: key ?? child.key,
          unitConstraints: constraints ?? unitConstraints,
          unitDecoration: unitDecoration ?? theme.unitDecoration,
          duration: _resolveDuration(item.duration),
          durationJitterMs: _resolveJitter(item.durationJitterMs),
          child: child,
        ),
        ItemType.flip => FlipWidgetUnit(
          key: key ?? child.key,
          unitConstraints: constraints ?? unitConstraints,
          unitDecoration: unitDecoration ?? theme.unitDecoration,
          duration: _resolveDuration(item.duration),
          durationJitterMs: _resolveJitter(item.durationJitterMs),
          flipAxis: item.flipAxis ?? Axis.horizontal,
          flipDirection: item.flipDirection ?? FlipDirection.forward,
          child: child,
        ),
      },
  };

  static List<FlipFlapItem> _itemsFromText({
    required final String text,
    required final UnitType unitType,
    required final int unitsInPack,
    required final Duration? duration,
    required final int? durationJitterMs,
    required final ItemType itemType,
  }) {
    final chars = unitType == UnitType.text
        ? <String>[text]
        : text.characters.toList();
    return chars
        .map(
          (final e) => switch (itemType) {
            ItemType.flap => FlipFlapTextItem.flap(
              e,
              unitType: unitType,
              unitsInPack: unitsInPack,
              duration: duration,
              durationJitterMs: durationJitterMs,
            ),
            ItemType.flip => FlipFlapTextItem.flip(
              e,
              unitType: unitType,
              unitsInPack: unitsInPack,
              duration: duration,
              durationJitterMs: durationJitterMs,
              flipAxis: Axis.horizontal,
            ),
          },
        )
        .toList();
  }

  Duration _resolveDuration(final Duration? itemDuration) =>
      itemDuration ?? unitDuration ?? const Duration(milliseconds: 200);

  int _resolveJitter(final int? itemJitter) =>
      itemJitter ?? unitDurationJitterMs ?? 50;
}
