import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question_model.dart';

/// Loads the question bank JSON for a given state from assets.
///
/// File naming convention (NEW): assets/question_bank/<stateCode>.json
/// Each file now holds ALL languages per question (question/options/
/// explanation are Map<String,...> keyed by language code), so there is
/// no more per-language file — languageCode is only used later, when a
/// screen picks which language to display via
/// QuestionModel.questionText(languageCode) / .optionsFor(languageCode).
///
/// Falls back to assets/question_bank/default.json if the state file is
/// missing.
class QuestionRepository {
  final Map<String, List<QuestionModel>> _cache = {};

  Future<List<QuestionModel>> loadQuestions({
    required String stateCode,
    required String languageCode,
  }) async {
    // Cache key is just the state now — the same loaded data serves every
    // language, since language is resolved at display time, not load time.
    final cacheKey = stateCode;
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    List<QuestionModel> questions;
    try {
      questions = await _loadFromAsset('assets/question_bank/$stateCode.json');
    } catch (_) {
      questions = await _loadFromAsset('assets/question_bank/default.json');
    }
    _cache[cacheKey] = questions;
    return questions;
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
