import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question_model.dart';

/// Loads the question bank JSON for a given state + language from assets.
/// File naming convention: assets/question_bank/<stateCode>_<languageCode>.json
/// Falls back to English if a state+language combo file is missing.
class QuestionRepository {
  final Map<String, List<QuestionModel>> _cache = {};

  Future<List<QuestionModel>> loadQuestions({
    required String stateCode,
    required String languageCode,
  }) async {
    final cacheKey = '${stateCode}_$languageCode';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    List<QuestionModel> questions;
    try {
      questions = await _loadFromAsset('assets/question_bank/${stateCode}_$languageCode.json');
    } catch (_) {
      // Fallback to English for that state, then to a generic bank.
      try {
        questions = await _loadFromAsset('assets/question_bank/${stateCode}_en.json');
      } catch (_) {
        questions = await _loadFromAsset('assets/question_bank/default_en.json');
      }
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
