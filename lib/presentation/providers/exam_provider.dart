import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/id_generator.dart';
import '../../data/models/exam_attempt_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/sign_model.dart';
import '../../data/repositories/question_repository.dart';
import '../../data/repositories/result_repository.dart';
import '../../data/repositories/sign_repository.dart';

enum ExamStatus { notStarted, inProgress, finished }

/// How many of the exam's questions are traffic-sign questions.
/// Taken out of AppConstants.questionsPerExam, so the total stays the same.
const int _signsPerExam = 2;

/// One exam question, already resolved for the exam's language. Wraps either
/// a QuestionModel or a SignModel so the exam screen doesn't care which.
class ExamItem {
  final String id;

  /// Asset path of the sign image, or null for plain text questions.
  final String? image;
  final String questionText;
  final List<String> options;
  final int correctIndex;

  const ExamItem({
    required this.id,
    required this.image,
    required this.questionText,
    required this.options,
    required this.correctIndex,
  });

  factory ExamItem.fromQuestion(QuestionModel q, String lang) => ExamItem(
        id: q.id,
        image: null,
        questionText: q.questionText(lang),
        options: q.optionsFor(lang),
        correctIndex: q.correctIndex,
      );

  factory ExamItem.fromSign(SignModel s, String lang) => ExamItem(
        id: s.id,
        image: s.image,
        questionText: s.questionText(lang),
        options: s.optionsFor(lang),
        correctIndex: s.correctIndex,
      );
}

/// Drives a single exam attempt: loading questions, tracking the current
/// question, recording answers/timeouts, and computing the final score.
class ExamProvider extends ChangeNotifier {
  final QuestionRepository _questionRepository;
  final SignRepository _signRepository;
  final ResultRepository _resultRepository = ResultRepository();

  ExamProvider(this._questionRepository, [SignRepository? signRepository])
      : _signRepository = signRepository ?? SignRepository();

  ExamStatus status = ExamStatus.notStarted;
  List<ExamItem> _items = [];
  int currentIndex = 0;
  final List<QuestionResult> _results = [];
  final Stopwatch _stopwatch = Stopwatch();
  String _stateCode = '';
  String _language = '';
  ExamAttempt? lastAttempt;

  ExamItem? get currentQuestion =>
      _items.isNotEmpty && currentIndex < _items.length ? _items[currentIndex] : null;

  int get totalQuestions => _items.length;
  int get currentQuestionNumber => currentIndex + 1;
  int get correctSoFar => _results.where((r) => r.isCorrect).length;

  Future<void> startExam({required String stateCode, required String languageCode}) async {
    _stateCode = stateCode;
    _language = languageCode;
    status = ExamStatus.inProgress;
    currentIndex = 0;
    _results.clear();
    lastAttempt = null;
    _stopwatch
      ..reset()
      ..start();

    // Signs are optional: if they fail to load, the exam is questions only.
    // Image-option signs are skipped because the exam screen only renders
    // text options.
    var signs = <SignModel>[];
    try {
      final all = await _signRepository.loadSigns(stateCode: stateCode);
      signs = all
          .where((s) => !s.hasImageOptions && s.optionsFor(languageCode).isNotEmpty)
          .toList()
        ..shuffle();
    } catch (e) {
      debugPrint('Exam: could not load signs: $e');
    }
    final signCount = math.min(_signsPerExam, signs.length);

    final questions = await _questionRepository.getExamQuestions(
      stateCode: stateCode,
      languageCode: languageCode,
      count: AppConstants.questionsPerExam - signCount,
    );

    final items = <ExamItem>[
      ...questions.map((q) => ExamItem.fromQuestion(q, languageCode)),
      ...signs.take(signCount).map((s) => ExamItem.fromSign(s, languageCode)),
    ]..shuffle();
    _items = items;

    notifyListeners();
  }

  /// Call when the user selects an answer, or with null on timeout.
  Future<void> submitAnswer(int? selectedIndex, {bool timedOut = false}) async {
    final q = currentQuestion;
    if (q == null) return;
    // QuestionResult stores a flat snapshot (plain String/List<String>),
    // which ExamItem already holds resolved for the exam's language.
    _results.add(QuestionResult(
      questionId: q.id,
      questionText: q.questionText,
      selectedIndex: selectedIndex,
      correctIndex: q.correctIndex,
      options: q.options,
      timedOut: timedOut,
    ));

    if (currentIndex < _items.length - 1) {
      currentIndex++;
      notifyListeners();
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    _stopwatch.stop();
    status = ExamStatus.finished;
    lastAttempt = ExamAttempt(
      id: generateSimpleId(),
      dateTime: DateTime.now(),
      totalQuestions: _items.length,
      correctAnswers: correctSoFar,
      timeTakenSeconds: _stopwatch.elapsed.inSeconds,
      stateCode: _stateCode,
      language: _language,
      questionResults: List.of(_results),
    );
    await _resultRepository.saveAttempt(lastAttempt!);
    notifyListeners();
  }

  void reset() {
    status = ExamStatus.notStarted;
    _items = [];
    currentIndex = 0;
    _results.clear();
    lastAttempt = null;
    notifyListeners();
  }
}
