import 'package:flutter/material.dart';
import 'package:flutter_flip_flap/models/flip_flap_item.dart';
import 'package:flutter_flip_flap/flip_flap_theme.dart';
import 'package:flutter_flip_flap/widgets/flap/flap_text_unit.dart';
import 'package:flutter_flip_flap/widgets/flap/flap_widget_unit.dart';
import 'package:flutter_flip_flap/widgets/flip/flip_text_unit.dart';
import 'package:flutter_flip_flap/widgets/flip/flip_widget_unit.dart';

class FlipFlapDisplay extends StatefulWidget {
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
    this.onItemsAnimationComplete,
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
    final VoidCallback? onItemsAnimationComplete,
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
    onItemsAnimationComplete: onItemsAnimationComplete,
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
  final VoidCallback? onItemsAnimationComplete;

  @override
  State<FlipFlapDisplay> createState() => _FlipFlapDisplayState();

  static List<FlipFlapItem> _itemsFromText({
    required final String text,
    required final UnitType unitType,
    required final int unitsInPack,
    required final Duration? duration,
    required final int? durationJitterMs,
    required final ItemType itemType,
  }) {
    final chars = unitType == UnitType.text ? <String>[text] : text.characters.toList();
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

}

class _FlipFlapDisplayState extends State<FlipFlapDisplay> {
  int _generation = 0;
  final Set<int> _pendingIndices = <int>{};

  @override
  void didUpdateWidget(covariant final FlipFlapDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshPendingIndices(oldWidget);
  }

  @override
  Widget build(final BuildContext context) {
    final theme = FlipFlapTheme.of(context);
    return DecoratedBox(
      decoration: widget.displayDecoration ?? theme.displayDecoration,
      child: Row(
        mainAxisAlignment: widget.mainAxisAlignment,
        children: [for (int i = 0; i < widget.items.length; i++) _buildUnit(widget.items[i], theme, i)],
      ),
    );
  }

  Widget _buildUnit(final FlipFlapItem item, final FlipFlapTheme theme, final int index) {
    final onComplete = widget.onItemsAnimationComplete == null ? null : () => _handleItemComplete(index, _generation);
    return switch (item) {
      FlipFlapTextItem(:final text, :final unitType, :final values, :final unitsInPack, :final type) => switch (type) {
      ItemType.flap => FlapTextUnit(
        key: Key('FlapTextUnit-$index-${widget.key}'),
        text: text,
        values: values,
        displayType: unitType,
        unitsInPack: unitsInPack,
        duration: item.duration ?? widget.unitDuration ?? const Duration(milliseconds: 400),
        durationJitterMs: _resolveJitter(item.durationJitterMs),
        unitConstraints: widget.unitConstraints,
        textStyle: widget.textStyle ?? theme.textStyle,
        unitDecoration: widget.unitDecoration ?? theme.unitDecoration,
        useShortestWay: widget.useShortestWay,
        onAnimationComplete: onComplete,
      ),
      ItemType.flip => FlipTextUnit(
        key: Key('FlipTextUnit-$index-${widget.key}'),
        text: text,
        values: values,
        displayType: unitType,
        unitsInPack: unitsInPack,
        duration: item.duration ?? widget.unitDuration ?? const Duration(milliseconds: 800),
        durationJitterMs: _resolveJitter(item.durationJitterMs),
        unitConstraints: widget.unitConstraints,
        textStyle: widget.textStyle ?? theme.textStyle,
        unitDecoration: widget.unitDecoration ?? theme.unitDecoration,
        useShortestWay: widget.useShortestWay,
        flipAxis: item.flipAxis ?? Axis.horizontal,
        flipDirection: item.flipDirection ?? FlipDirection.forward,
        onAnimationComplete: onComplete,
      ),
    },
    FlipFlapWidgetItem(:final key, :final child, :final constraints, :final type, :final animationTrigger) =>
      switch (type) {
        ItemType.flap => FlapWidgetUnit(
          key: Key('FlapWidgetUnit-$index-$key'),
          unitConstraints: constraints ?? widget.unitConstraints,
          unitDecoration: widget.unitDecoration ?? theme.unitDecoration,
          duration: item.duration ?? widget.unitDuration ?? const Duration(milliseconds: 400),
          durationJitterMs: _resolveJitter(item.durationJitterMs),
          animationTrigger: animationTrigger,
          onAnimationComplete: onComplete,
          child: child,
        ),
        ItemType.flip => FlipWidgetUnit(
          key: Key('FlipWidgetUnit-$index-$key'),
          unitConstraints: constraints ?? widget.unitConstraints,
          unitDecoration: widget.unitDecoration ?? theme.unitDecoration,
          duration: item.duration ?? widget.unitDuration ?? const Duration(milliseconds: 800),
          durationJitterMs: _resolveJitter(item.durationJitterMs),
          flipAxis: item.flipAxis ?? Axis.horizontal,
          flipDirection: item.flipDirection ?? FlipDirection.forward,
          animationTrigger: animationTrigger,
          onAnimationComplete: onComplete,
          child: child,
        ),
      },
    };
  }

  void _refreshPendingIndices(final FlipFlapDisplay oldWidget) {
    final newPending = <int>{};
    final int commonLength = oldWidget.items.length < widget.items.length ? oldWidget.items.length : widget.items.length;
    for (int i = 0; i < commonLength; i++) {
      if (_shouldAnimate(oldWidget.items[i], widget.items[i])) {
        newPending.add(i);
      }
    }
    if (newPending.isNotEmpty) {
      _pendingIndices
        ..clear()
        ..addAll(newPending);
      _generation++;
      return;
    }
    if (oldWidget.items.length != widget.items.length) {
      _pendingIndices.clear();
    }
  }

  bool _shouldAnimate(final FlipFlapItem oldItem, final FlipFlapItem newItem) {
    if (oldItem is FlipFlapTextItem && newItem is FlipFlapTextItem) {
      return oldItem.text != newItem.text;
    }
    if (oldItem is FlipFlapWidgetItem && newItem is FlipFlapWidgetItem) {
      assert(
        (oldItem.animationTrigger == null) == (newItem.animationTrigger == null),
        'animationTrigger should be consistently null or non-null for a FlipFlapWidgetItem index.',
      );
      if (oldItem.animationTrigger != null) {
        return oldItem.animationTrigger != newItem.animationTrigger;
      }
      return oldItem.child.key != newItem.child.key ||
          (oldItem.child.key == null && !identical(oldItem.child, newItem.child));
    }
    return false;
  }

  void _handleItemComplete(final int index, final int generation) {
    if (generation != _generation) return;
    if (_pendingIndices.isEmpty) return;
    if (_pendingIndices.remove(index) && _pendingIndices.isEmpty) {
      widget.onItemsAnimationComplete?.call();
    }
  }

  int _resolveJitter(final int? itemJitter) => itemJitter ?? widget.unitDurationJitterMs ?? 50;
}
