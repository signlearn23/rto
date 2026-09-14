/// Traffic sign model, structurally identical to QuestionModel but always
/// image-first: {
///   "id": "sign_001",
///   "category": "Mandatory",
///   "image": "assets/images/signs/no_entry.png",
///   "question": { "en": "What does this sign indicate?", "ta": "...", ... },
///   "options": { "en": [...], "ta": [...], ... },
///   "correctIndex": 0,
///   "explanation": { "en": "...", ... }
/// }
class SignModel {
  final String id;
  final String category;
  final String image;
  final Map<String, String> question;
  final Map<String, List<String>> options;
  final int correctIndex;
  final Map<String, String>? explanation;

  const SignModel({
    required this.id,
    required this.category,
    required this.image,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  factory SignModel.fromJson(Map<String, dynamic> json) {
    return SignModel(
      id: json['id'] as String,
      category: json['category'] as String? ?? '',
      image: json['image'] as String,
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
        'category': category,
        'image': image,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        if (explanation != null) 'explanation': explanation,
      };

  String questionText(String lang) => question[lang] ?? question['en'] ?? '';

  List<String> optionsFor(String lang) => options[lang] ?? options['en'] ?? const [];

  String? explanationText(String lang) => explanation?[lang] ?? explanation?['en'];
}
