import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../data/models/question_model.dart';
import '../../../data/models/sign_model.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../data/repositories/sign_repository.dart';
import '../../providers/app_state_provider.dart';

const int _questionsPerAd = 6;

/// Unified view over a QuestionModel or SignModel so the practice flow
/// can render either without caring which one it is.
abstract class _PracticeItem {
  String get id;
  String? get image;
  String questionText(String lang);
  List<String> optionsFor(String lang);
  int get correctIndex;
  String? explanationText(String lang);
}

class _QuestionPracticeItem extends _PracticeItem {
  final QuestionModel model;
  _QuestionPracticeItem(this.model);

  @override
  String get id => model.id;
  @override
  String? get image => null;
  @override
  String questionText(String lang) => model.questionText(lang);
  @override
  List<String> optionsFor(String lang) => model.optionsFor(lang);
  @override
  int get correctIndex => model.correctIndex;
  @override
  String? explanationText(String lang) => model.explanationText(lang);
}

class _SignPracticeItem extends _PracticeItem {
  final SignModel model;
  _SignPracticeItem(this.model);

  @override
  String get id => model.id;
  @override
  String? get image => model.image;
  @override
  String questionText(String lang) => model.questionText(lang);
  @override
  List<String> optionsFor(String lang) => model.optionsFor(lang);
  @override
  int get correctIndex => model.correctIndex;
  @override
  String? explanationText(String lang) => model.explanationText(lang);
}

sealed class _Slide {}
class _QuestionSlide extends _Slide {
  final _PracticeItem item;
  _QuestionSlide(this.item);
}
class _AdSlide extends _Slide {
  final int slotKey;
  _AdSlide(this.slotKey);
}

class PracticeQuestionScreen extends StatefulWidget {
  final String? topic; // null = practice across all topics (questions + signs)
  const PracticeQuestionScreen({super.key, this.topic});

  @override
  State<PracticeQuestionScreen> createState() => _PracticeQuestionScreenState();
}

class _PracticeQuestionScreenState extends State<PracticeQuestionScreen> {
  final _questionRepo = QuestionRepository();
  final _signRepo = SignRepository();
  final _pageController = PageController();
  final Map<int, NativeAd> _loadedAds = {};
  final Set<int> _adLoaded = {};

  List<_Slide> _slides = [];
  final Map<int, int?> _selectedAt = {};
  int _correct = 0;
  bool _loading = true;
  String _lang = 'en';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final appState = context.read<AppStateProvider>();
    final stateCode = appState.selectedState ?? 'tamilnadu';
    final languageCode = appState.selectedLanguage ?? 'en';

    List<_PracticeItem> items;
    if (widget.topic != null) {
      final questions =
          (await _questionRepo.groupedByTopic(stateCode: stateCode, languageCode: languageCode))[widget.topic] ??
              [];
      items = questions.map((q) => _QuestionPracticeItem(q)).toList();
    } else {
      final questions = await _questionRepo.allQuestions(stateCode: stateCode, languageCode: languageCode);
      final signs = await _signRepo.loadSigns(stateCode: stateCode);
      items = [
        ...questions.map((q) => _QuestionPracticeItem(q)),
        ...signs.map((s) => _SignPracticeItem(s)),
      ]..shuffle();
    }

    final slides = <_Slide>[];
    var since = 0, adSlot = 0;
    for (final item in items) {
      slides.add(_QuestionSlide(item));
      if (++since == _questionsPerAd) {
        slides.add(_AdSlide(adSlot++));
        since = 0;
      }
    }

    setState(() {
      _lang = languageCode;
      _slides = slides;
      _loading = false;
    });
  }

  int get _questionCount => _slides.whereType<_QuestionSlide>().length;

  void _selectOption(int slideIndex, int optionIndex) {
    final item = (_slides[slideIndex] as _QuestionSlide).item;
    if (_selectedAt[slideIndex] != null) return;
    setState(() {
      _selectedAt[slideIndex] = optionIndex;
      if (optionIndex == item.correctIndex) _correct++;
    });
  }

  void _goNext(int currentIndex) {
    if (currentIndex == _slides.length - 1) {
      _showResult();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Practice Complete'),
        content: Text('You got $_correct / $_questionCount correct.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  NativeAd _adFor(int slotKey) {
    return _loadedAds.putIfAbsent(slotKey, () {
      final ad = NativeAd(
        adUnitId: 'ca-app-pub-3699335518824613/9673004091',
        factoryId: 'advancedNativeAd', // must match the NativeAdFactory registered natively
        listener: NativeAdListener(
          onAdLoaded: (_) => setState(() => _adLoaded.add(slotKey)),
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _loadedAds.remove(slotKey);
            setState(() {});
          },
        ),
        request: const AdRequest(),
      )..load();
      return ad;
    });
  }

  @override
  void dispose() {
    for (final ad in _loadedAds.values) ad.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_slides.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.topic ?? 'Practice')),
        body: const Center(child: Text('No questions available yet.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.topic ?? 'Practice')),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // block swipe-skipping ad/question slides
        itemCount: _slides.length,
        itemBuilder: (context, index) {
          final slide = _slides[index];
          if (slide is _AdSlide) {
            return _AdSlideView(
              ad: _loadedAds[slide.slotKey] ?? _adFor(slide.slotKey),
              isLoaded: _adLoaded.contains(slide.slotKey),
              onContinue: () => _goNext(index),
            );
          }
          final item = (slide as _QuestionSlide).item;
          final questionNumber = _slides.take(index + 1).whereType<_QuestionSlide>().length;
          return _QuestionSlideView(
            item: item,
            lang: _lang,
            questionNumber: questionNumber,
            totalQuestions: _questionCount,
            selected: _selectedAt[index],
            onSelect: (i) => _selectOption(index, i),
            onNext: () => _goNext(index),
          );
        },
      ),
    );
  }
}

class _QuestionSlideView extends StatelessWidget {
  final _PracticeItem item;
  final String lang;
  final int questionNumber;
  final int totalQuestions;
  final int? selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  const _QuestionSlideView({
    required this.item,
    required this.lang,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final options = item.optionsFor(lang);
    final explanation = item.explanationText(lang);
    final image = item.image;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: questionNumber / totalQuestions),
          const SizedBox(height: 8),
          Text('Question $questionNumber of $totalQuestions', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          if (image != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(image, height: 150, fit: BoxFit.contain),
                ),
              ),
            ),
          Text(item.questionText(lang), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          ...List.generate(options.length, (i) {
            final isSelected = selected == i;
            final isCorrect = i == item.correctIndex;
            Color? color;
            if (selected != null) {
              if (isCorrect) color = Colors.green.withOpacity(0.15);
              else if (isSelected) color = Colors.red.withOpacity(0.15);
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelect(i),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(options[i])),
                    if (selected != null && isCorrect) const Icon(Icons.check_circle, color: Colors.green),
                    if (selected != null && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.red),
                  ]),
                ),
              ),
            );
          }),
          if (selected != null && explanation != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Text('💡 $explanation', style: TextStyle(color: Colors.grey.shade700)),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selected == null ? null : onNext,
              child: Text(questionNumber == totalQuestions ? 'Finish' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdSlideView extends StatelessWidget {
  final NativeAd ad;
  final bool isLoaded;
  final VoidCallback onContinue;

  const _AdSlideView({required this.ad, required this.isLoaded, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text('A quick break', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Expanded(
            child: isLoaded
                ? SizedBox(width: double.infinity, child: AdWidget(ad: ad))
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: onContinue, child: const Text('Continue')),
          ),
        ],
      ),
    );
  }
}
