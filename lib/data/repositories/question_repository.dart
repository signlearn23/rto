import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question_model.dart';

/// Loads the question bank JSON for a given state from assets.
///
/// Each state now has TWO files, both in the same multi-language format
/// (question/options/explanation are Map<String,...> keyed by language
/// code) â€” split by question type rather than by language:
///   assets/question_bank/<stateCode>.json        (plain text questions)
///   assets/question_bank/<stateCode>_signs.json  (sign/image questions)
/// The two are merged into one list after loading, so every other part
/// of the app just sees a single combined question list.
///
/// Falls back to default.json / default_signs.json if a state's file is
/// missing. A missing *_signs.json is fine â€” a state with no sign
/// questions yet just gets an empty list for that part, no error.
class QuestionRepository {
  final Map<String, List<QuestionModel>> _cache = {};

  Future<List<QuestionModel>> loadQuestions({
    required String stateCode,
    required String languageCode,
  }) async {
    // Cache key is just the state now â€” the same loaded data serves every
    // language, since language is resolved at display time, not load time.
    final cacheKey = stateCode;
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    final textQuestions = await _loadWithFallback(
      primary: 'assets/question_bank/$stateCode.json',
      fallback: 'assets/question_bank/default.json',
    );
    final signQuestions = await _loadWithFallback(
      primary: 'assets/question_bank/${stateCode}_signs.json',
      fallback: 'assets/question_bank/default_signs.json',
      allowEmpty: true,
    );

    final combined = [...textQuestions, ...signQuestions];
    _cache[cacheKey] = combined;
    return combined;
  }

  /// Tries [primary], then [fallback]. If both are missing/unparseable and
  /// [allowEmpty] is true, returns an empty list instead of throwing â€”
  /// used for the sign-question file, which some states may not have yet.
  Future<List<QuestionModel>> _loadWithFallback({
    required String primary,
    required String fallback,
    bool allowEmpty = false,
  }) async {
    try {
      return await _loadFromAsset(primary);
    } catch (_) {
      try {
        return await _loadFromAsset(fallback);
      } catch (_) {
        if (allowEmpty) return [];
        rethrow;
      }
    }
  }

  Future<List<QuestionModel>> _loadFromAsset(String path) async {
    final raw = await rootBundle.loadString(path);
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  /// Returns [count] random, non-repeating questions for an exam attempt.
  Future<List<QuestionModel>> getExamQuestions({
    required String stateCode,
    required String languageCode,
    required int count,
  }) async {
    final all = List<QuestionModel>.from(
      await loadQuestions(stateCode: stateCode, languageCode: languageCode),
    );
    all.shuffle(Random());
    return all.take(count).toList();
  }

  /// Returns every question for a state, ungrouped â€” used by screens that
  /// offer an "All topics" practice mode alongside per-topic practice.
  Future<List<QuestionModel>> allQuestions({
    required String stateCode,
    required String languageCode,
  }) async {
    return loadQuestions(stateCode: stateCode, languageCode: languageCode);
  }

  /// Groups questions by topic for the Question Bank / Practice screens.
  Future<Map<String, List<QuestionModel>>> groupedByTopic({
    required String stateCode,
    required String languageCode,
  }) async {
    final all = await loadQuestions(stateCode: stateCode, languageCode: languageCode);
    final Map<String, List<QuestionModel>> grouped = {};
    for (final q in all) {
      grouped.putIfAbsent(q.topic, () => []).add(q);
    }
    return grouped;
  }
}
