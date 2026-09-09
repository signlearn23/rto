class QuestionResult {
  final String questionId;
  final String questionText;
  final int? selectedIndex;
  final int correctIndex;
  final List<String> options;
  final bool timedOut;

  bool get isCorrect => selectedIndex != null && selectedIndex == correctIndex;

  QuestionResult({
    required this.questionId,
    required this.questionText,
    required this.selectedIndex,
    required this.correctIndex,
    required this.options,
    required this.timedOut,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'questionText': questionText,
        'selectedIndex': selectedIndex,
        'correctIndex': correctIndex,
        'options': options,
        'timedOut': timedOut,
      };

  factory QuestionResult.fromJson(Map<String, dynamic> json) => QuestionResult(
        questionId: json['questionId'],
        questionText: json['questionText'],
        selectedIndex: json['selectedIndex'],
        correctIndex: json['correctIndex'],
        options: List<String>.from(json['options']),
        timedOut: json['timedOut'] ?? false,
      );
}

class ExamAttempt {
  final String id;
  final DateTime dateTime;
  final int totalQuestions;
  final int correctAnswers;
  final int timeTakenSeconds;
  final String stateCode;
  final String language;
  final List<QuestionResult> questionResults;

  bool get passed => correctAnswers >= (totalQuestions * 0.7).round();

  ExamAttempt({
    required this.id,
    required this.dateTime,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTakenSeconds,
    required this.stateCode,
    required this.language,
    required this.questionResults,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'timeTakenSeconds': timeTakenSeconds,
        'stateCode': stateCode,
        'language': language,
        'questionResults': questionResults.map((e) => e.toJson()).toList(),
      };

  factory ExamAttempt.fromJson(Map<String, dynamic> json) => ExamAttempt(
        id: json['id'],
        dateTime: DateTime.parse(json['dateTime']),
        totalQuestions: json['totalQuestions'],
        correctAnswers: json['correctAnswers'],
        timeTakenSeconds: json['timeTakenSeconds'],
        stateCode: json['stateCode'],
        language: json['language'],
        questionResults: (json['questionResults'] as List)
            .map((e) => QuestionResult.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}
