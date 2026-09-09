class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String topic;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.topic,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json['id'] as String,
        question: json['question'] as String,
        options: List<String>.from(json['options'] as List),
        correctIndex: json['correctIndex'] as int,
        topic: json['topic'] as String? ?? 'General',
        explanation: json['explanation'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'topic': topic,
        'explanation': explanation,
      };
}
