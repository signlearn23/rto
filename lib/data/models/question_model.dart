
class QuestionModel {
  final String id;
  final String topic;
  final Map<String, String> question;
  final Map<String, List<String>> options;
  final int correctIndex;
  final Map<String, String>? explanation;

  const QuestionModel({
    required this.id,
    required this.topic,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      topic: json['topic'] as String? ?? '',
      question: Map<String, String>.from(json['question'] as Map),
      options: (json['options'] as Map).map(
        (key, value) => MapEntry(key as String, List<String>.from(value as List)),
      ),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] != null
          ? Map<String, String>.from(json['explanation'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        if (explanation != null) 'explanation': explanation,
      };

  /// Falls back to English, then to an empty value, if a language is missing.
  String questionText(String lang) => question[lang] ?? question['en'] ?? '';

  List<String> optionsFor(String lang) => options[lang] ?? options['en'] ?? const [];

  String? explanationText(String lang) => explanation?[lang] ?? explanation?['en'];
}
