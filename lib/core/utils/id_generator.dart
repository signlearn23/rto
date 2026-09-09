import 'dart:math';

/// Simple unique-ish ID generator (timestamp + random suffix).
/// Avoids pulling in an extra package just for local IDs.
String generateSimpleId() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  final rand = Random().nextInt(999999).toString().padLeft(6, '0');
  return '$ts-$rand';
}
