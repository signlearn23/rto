import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/sign_model.dart';

/// Loads the traffic-sign bank JSON for a given state from assets:
///   assets/sign_bank/<stateCode>.json
/// Falls back to default.json only if a state's file is missing.
/// Parse errors are NOT swallowed: bad entries are logged and skipped.
class SignRepository {
  final Map<String, List<SignModel>> _cache = {};

  Future<List<SignModel>> loadSigns({required String stateCode}) async {
    if (_cache.containsKey(stateCode)) return _cache[stateCode]!;

    final signs = await _loadWithFallback(
      primary: 'assets/sign_bank/$stateCode.json',
      fallback: 'assets/sign_bank/default.json',
    );

    _cache[stateCode] = signs;
    return signs;
  }

  Future<List<SignModel>> _loadWithFallback({
    required String primary,
    required String fallback,
  }) async {
    try {
      return await _loadFromAsset(primary);
    } on FlutterError catch (e) {
      // rootBundle throws FlutterError when the asset isn't found.
      debugPrint('Sign asset missing ($primary): $e. Using fallback.');
      return await _loadFromAsset(fallback);
    }
    // Other errors (e.g. invalid JSON) are not caught, so they surface.
  }

  Future<List<SignModel>> _loadFromAsset(String path) async {
    final raw = await rootBundle.loadString(path);
    final List<dynamic> decoded = jsonDecode(raw);
    final result = <SignModel>[];
    for (final e in decoded) {
      try {
        result.add(SignModel.fromJson(Map<String, dynamic>.from(e as Map)));
      } catch (err) {
        debugPrint('Bad sign entry ${(e as Map)['id']} in $path: $err');
      }
    }
    return result;
  }

  Future<Map<String, List<SignModel>>> groupedByCategory({
    required String stateCode,
  }) async {
    final all = await loadSigns(stateCode: stateCode);
    final Map<String, List<SignModel>> grouped = {};
    for (final s in all) {
      grouped.putIfAbsent(s.category, () => []).add(s);
    }
    return grouped;
  }
}
