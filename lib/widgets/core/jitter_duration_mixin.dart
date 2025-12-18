import 'dart:math';

/// Provides a reusable helper to add jitter to a base [Duration].
mixin JitterDurationMixin {
  final Random _jitterRandom = Random();

  Duration effectiveDuration({
    required final Duration base,
    required final int jitterMs,
  }) {
    final jitter = jitterMs.clamp(0, 1000);
    if (jitter <= 0) return base;
    final delta = _jitterRandom.nextInt(jitter + 1);
    return base + Duration(milliseconds: delta);
  }
}
