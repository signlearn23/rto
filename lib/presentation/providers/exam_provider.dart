import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/id_generator.dart';
import '../../data/models/exam_attempt_model.dart';
import '../../data/models/question_model.dart';
import '../../data/repositories/question_repository.dart';
import '../../data/repositories/result_repository.dart';

enum ExamStatus { notStarted, inProgress, finished }

/// Drives a single exam attempt: loading questions, tracking the current
/// question, recording answers/timeouts, and computing the final score.
class ExamProvider extends ChangeNotifier {
  final QuestionRepository _questionRepository;
  final ResultRepository _resultRepository = ResultRepository();

  ExamProvider(this._questionRepository);

  ExamStatus status = ExamStatus.notStarted;
  List<QuestionModel> _questions = [];
  int currentIndex = 0;
  final List<QuestionResult> _results = [];
  final Stopwatch _stopwatch = Stopwatch();
  String _stateCode = '';
  String _language = '';
  ExamAttempt? lastAttempt;

  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty && currentIndex < _questions.length ? _questions[currentIndex] : null;

  int get totalQuestions => _questions.length;
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
    _questions = await _questionRepository.getExamQuestions(
      stateCode: stateCode,
      languageCode: languageCode,
      count: AppConstants.questionsPerExam,
    );
    notifyListeners();
  }

  /// Call when the user selects an answer, or with null on timeout.
  Future<void> submitAnswer(int? selectedIndex, {bool timedOut = false}) async {
    final q = currentQuestion;
    if (q == null) return;
    // QuestionModel now stores question/options per language
    // (Map<String,...>), so resolve them for the exam's language before
    // saving the flat snapshot into QuestionResult (which still expects
    // plain String/List<String> — that model is unchanged).
    _results.add(QuestionResult(
      questionId: q.id,
      questionText: q.questionText(_language),
      selectedIndex: selectedIndex,
      correctIndex: q.correctIndex,
      options: q.optionsFor(_language),
      timedOut: timedOut,
    ));

    if (currentIndex < _questions.length - 1) {
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
      totalQuestions: _questions.length,
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
    _questions = [];
    currentIndex = 0;
    _results.clear();
    lastAttempt = null;
    notifyListeners();
  }
}
