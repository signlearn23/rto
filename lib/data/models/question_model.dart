/// Question model matching the new localized JSON shape, e.g.:
/// {
///   "id": "rto_q_038",
///   "topic": "Road Markings",
///   "image": "assets/images/signs/no_entry.png",   // optional â€” question shows a sign
///   "question": { "en": "...", "ta": "...", "hi": "...", "te": "...", "ml": "..." },
///   "options": { "en": [...], "ta": [...], ... },   // omit if using optionImages instead
///   "optionImages": ["assets/images/signs/a.png", "assets/images/signs/b.png"], // optional â€” options ARE signs
///   "correctIndex": 0,
///   "explanation": { "en": "...", ... }
/// }
///
/// Three question shapes, all using the same fields above:
///  - Text question, text options: set "question" + "options", leave
///    "image" and "optionImages" out.
///  - Sign question, text options: also set "image" ("The sign
///    represents...").
///  - Text question, sign options: set "optionImages" instead of
///    "options" ("Which sign denotes...?"). Images aren't translated, so
///    the same optionImages list is used for every language.
class QuestionModel {
  final String id;
  final String topic;
  final String? image;
  final Map<String, String> question;
  final Map<String, List<String>>? options;
  final List<String>? optionImages;
  final int correctIndex;
  final Map<String, String>? explanation;

  const QuestionModel({
    required this.id,
    required this.topic,
    this.image,
    required this.question,
    this.options,
    this.optionImages,
    required this.correctIndex,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      topic: json['topic'] as String? ?? '',
      image: json['image'] as String?,
      question: Map<String, String>.from(json['question'] as Map),
      options: json['options'] != null
          ? (json['options'] as Map).map(
              (key, value) => MapEntry(key as String, List<String>.from(value as List)),
            )
          : null,
      optionImages: json['optionImages'] != null ? List<String>.from(json['optionImages'] as List) : null,
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] != null
          ? Map<String, String>.from(json['explanation'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        if (image != null) 'image': image,
        'question': question,
        if (options != null) 'options': options,
        if (optionImages != null) 'optionImages': optionImages,
        'correctIndex': correctIndex,
        if (explanation != null) 'explanation': explanation,
      };

  bool get hasImage => image != null && image!.isNotEmpty;

  /// True when answer choices are sign images rather than text.
  bool get hasImageOptions => optionImages != null && optionImages!.isNotEmpty;

  /// Falls back to English, then to an empty value, if a language is missing.
  String questionText(String lang) => question[lang] ?? question['en'] ?? '';

  List<String> optionsFor(String lang) => options?[lang] ?? options?['en'] ?? const [];

  /// Number of answer choices, whichever option type this question uses.
  int optionCount(String lang) => hasImageOptions ? optionImages!.length : optionsFor(lang).length;

  String? explanationText(String lang) => explanation?[lang] ?? explanation?['en'];
}
