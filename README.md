flutter_flip_flap - a customizable split-flap / flip display for Flutter. Ideal for clocks, boards, counters, and any UI that needs mechanical card or 3D flip effects for text and widgets.

## Features
- Text items and arbitrary widget items on the same rail (`FlipFlapTextItem` and `FlipFlapWidgetItem`).
- Two modes: mechanical flap (split) and 3D flip, with axis and direction control.
- Flexible symbol sets via `UnitType` or your own `values`, control of cards per pack, and direction.
- Theming through `FlipFlapTheme` or per-widget `Decoration` / `TextStyle`.
- Clock demo with mixed content in `example/lib/main.dart`.

## Live example
You can see example **here**: https://peterombodi.github.io/flutter_flip_flap/

## Installation
```bash
flutter pub add flutter_flip_flap
```
or add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_flip_flap: ^0.2.0
```

## Quick start
Minimal text board:
```dart
import 'package:flutter_flip_flap/flutter_flip_flap.dart';

class SimpleBoard extends StatelessWidget {
  const SimpleBoard({super.key});

  @override
  Widget build(BuildContext context) {
    const text = 'HELLO';
    const unit = BoxConstraints(minWidth: 42, minHeight: 72, maxHeight: 72);

    return FlipFlapDisplay.fromText(
      text: text,
      unitConstraints: unit,
      textStyle: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700),
      displayDecoration: const BoxDecoration(color: Colors.transparent),
      unitDecoration: const BoxDecoration(
        color: Color(0xFF1F1F1F),
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
    );
  }
}
```

## Advanced usage
Mix widgets and text cards and tune animation:
```dart
Widget build(BuildContext context) {
  return FlipFlapDisplay(
    unitConstraints: const BoxConstraints(minWidth: 56, minHeight: 96, maxHeight: 96),
    textStyle: const TextStyle(fontSize: 48, color: Colors.orangeAccent),
    items: const [
      // Mechanical flap
      FlipFlapWidgetItem.flap(child: Icon(Icons.flight_takeoff, size: 48)),
      FlipFlapTextItem.flap('A', unitType: UnitType.character, unitsInPack: 3),
      // 3D flip (horizontal axis, backward direction)
      FlipFlapWidgetItem.flip(
        child: Icon(Icons.swap_horiz, size: 48),
        flipAxis: Axis.horizontal,
        flipDirection: FlipDirection.backward,
      ),
      // Not limited by alphabet
      FlipFlapTextItem.flap('12', unitType: UnitType.text),
    ],
  );
}
```

### Key parameters
- `unitConstraints` - required card sizing (minWidth/minHeight).
- `unitsInPack` - how many intermediate units the animation scrolls (>=2 adds rolling effect).
- `unitType` / `values` - allowed symbols or custom list.
- `useShortestWay` - pick shortest path on the circular alphabet or not.
- `ItemType` / `flipAxis` / `flipDirection` - choose mechanical flap or 3D flip and its orientation.
- `duration` / `durationJitterMs` - per item or per display animation timing.
- `displayDecoration` / `unitDecoration` / `textStyle` - per-widget styling or via theme.

### Theming
Add `FlipFlapTheme` to `ThemeData.extensions` to reuse styles:
```dart
final theme = ThemeData(
  extensions: const [
    FlipFlapTheme(
      unitDecoration: BoxDecoration(
        color: Color(0xFF303030),
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      displayDecoration: BoxDecoration(color: Colors.transparent),
      textStyle: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ],
);
```
If not provided, built-in light and dark presets are used.

## Example app
Run the demo clock:
```bash
cd example
flutter run
```
Example code: `example/lib/main.dart`.

## Feedback
- Repo / issues: https://github.com/PeterOmbodi/flutter_flip_flap/issues
- Pub.dev: https://pub.dev/packages/flutter_flip_flap
