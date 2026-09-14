import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question_model.dart';

/// Loads the question bank JSON for a given state from assets:
///   assets/question_bank/<stateCode>.json
/// Falls back to default.json if a state's file is missing.
class QuestionRepository {
  final Map<String, List<QuestionModel>> _cache = {};

  Future<List<QuestionModel>> loadQuestions({
    required String stateCode,
    required String languageCode,
  }) async {
    final cacheKey = stateCode;
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    final questions = await _loadWithFallback(
      primary: 'assets/question_bank/$stateCode.json',
      fallback: 'assets/question_bank/default.json',
    );

    _cache[cacheKey] = questions;
    return questions;
  }

  Future<List<QuestionModel>> _loadWithFallback({
    required String primary,
    required String fallback,
  }) async {
    try {
      return await _loadFromAsset(primary);
    } catch (_) {
      return await _loadFromAsset(fallback);
    }
  }

  Future<List<QuestionModel>> _loadFromAsset(String path) async {
    final raw = await rootBundle.loadString(path);
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

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

  Future<List<QuestionModel>> allQuestions({
    required String stateCode,
    required String languageCode,
  }) async {
    return loadQuestions(stateCode: stateCode, languageCode: languageCode);
  }

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
