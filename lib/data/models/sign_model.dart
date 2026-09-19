/// Traffic sign model. Supports two question types:
///
/// 1. image_to_text: a sign image is shown, options are text per language.
/// {
///   "id": "sign_001",
///   "type": "image_to_text",
///   "category": "Warning",
///   "image": "assets/images/signs/school_crossing.png",
///   "question": { "en": "...", "ta": "..." },
///   "options": { "en": [...], "ta": [...] },
///   "correctIndex": 0,
///   "explanation": { "en": "...", "ta": "..." }
/// }
///
/// 2. text_to_image: a text question is shown, options are images.
/// {
///   "id": "sign_002",
///   "type": "text_to_image",
///   "category": "Warning",
///   "question": { "en": "...", "ta": "..." },
///   "options": { "type": "image", "items": ["assets/.../a.png", ...] },
///   "correctIndex": 0,
///   "explanation": { "en": "...", "ta": "..." }
/// }
class SignModel {
  final String id;
  final String category;

  /// 'image_to_text' or 'text_to_image'.
  final String type;

  /// Null for text_to_image questions.
  final String? image;

  final Map<String, String> question;

  /// Text options per language. Empty for image options.
  final Map<String, List<String>> options;

  /// Image option asset paths. Empty for text options.
  final List<String> imageOptions;

  final int correctIndex;
  final Map<String, String>? explanation;

  const SignModel({
    required this.id,
    required this.category,
    required this.type,
    required this.image,
    required this.question,
    required this.options,
    required this.imageOptions,
    required this.correctIndex,
    this.explanation,
  });

  bool get hasImageOptions => imageOptions.isNotEmpty;

  factory SignModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as Map;
    final isImageOptions = rawOptions['type'] == 'image';

    return SignModel(
      id: json['id'] as String,
      category: json['category'] as String? ?? '',
      type: json['type'] as String? ?? 'image_to_text',
      image: json['image'] as String?,
      question: Map<String, String>.from(json['question'] as Map),
      options: isImageOptions
          ? const {}
          : rawOptions.map(
              (k, v) => MapEntry(k as String, List<String>.from(v as List)),
            ),
      imageOptions: isImageOptions
          ? List<String>.from(rawOptions['items'] as List)
          : const [],
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] != null
          ? Map<String, String>.from(json['explanation'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'category': category,
        if (image != null) 'image': image,
        'question': question,
        'options': hasImageOptions
            ? {'type': 'image', 'items': imageOptions}
            : options,
        'correctIndex': correctIndex,
        if (explanation != null) 'explanation': explanation,
      };

  String questionText(String lang) => question[lang] ?? question['en'] ?? '';

  List<String> optionsFor(String lang) =>
      options[lang] ?? options['en'] ?? const [];

  String? explanationText(String lang) =>
      explanation?[lang] ?? explanation?['en'];
}
