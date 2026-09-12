import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/question_model.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../data/services/bookmark_store.dart';
import '../../providers/app_state_provider.dart';

enum _Filter { all, bookmarked }

/// Internal list item: either a numbered question or an ad break.
/// Kept as one flat list so ListView.builder can render both without
/// special-casing indices in the build method.
class _QuestionItem {
  final int number;
  final QuestionModel question;
  const _QuestionItem(this.number, this.question);
}

class _AdBreak {
  const _AdBreak();
}

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  final _repo = QuestionRepository();
  final _random = math.Random();

  List<QuestionModel> _allQuestions = [];
  List<dynamic> _items = []; // _QuestionItem or _AdBreak
  bool _loading = true;
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await BookmarkStore.instance.init();
    final appState = context.read<AppStateProvider>();
    final grouped = await _repo.groupedByTopic(
      stateCode: appState.selectedState ?? 'tamilnadu',
      languageCode: appState.selectedLanguage ?? 'en',
    );
    if (!mounted) return;
    setState(() {
      _allQuestions = grouped.values.expand((qs) => qs).toList();
      _loading = false;
    });
    _rebuildItems();
  }

  List<QuestionModel> get _filteredQuestions {
    if (_filter == _Filter.bookmarked) {
      return _allQuestions.where((q) => BookmarkStore.instance.isBookmarked(q.id)).toList();
    }
    return _allQuestions;
  }

  // Random gap between ads: somewhere between 4 and 8 questions each time
  // (e.g. 8, then 5, then 6, then 4 ... never the same fixed spacing).
  int _randomGap() => 4 + _random.nextInt(5);

  void _rebuildItems() {
    final questions = _filteredQuestions;
    final items = <dynamic>[];
    var untilNextAd = _randomGap();
    for (var i = 0; i < questions.length; i++) {
      items.add(_QuestionItem(i + 1, questions[i]));
      untilNextAd--;
      if (untilNextAd <= 0 && i != questions.length - 1) {
        items.add(const _AdBreak());
        untilNextAd = _randomGap();
      }
    }
    setState(() => _items = items);
  }

  void _onFilterChanged(_Filter filter) {
    if (filter == _filter) return;
    setState(() => _filter = filter);
    _rebuildItems();
  }

  Future<void> _onBookmarkToggled(String questionId) async {
    await BookmarkStore.instance.toggle(questionId);
    if (!mounted) return;
    // Only need to rebuild the list if the bookmarked filter is active —
    // un-bookmarking there should drop the card immediately. "All" view
    // just needs the icon on the card to repaint, which setState below
    // handles either way.
    if (_filter == _Filter.bookmarked) {
      _rebuildItems();
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final lang = appState.selectedLanguage ?? 'en';
    final bookmarkedCount =
        _allQuestions.where((q) => BookmarkStore.instance.isBookmarked(q.id)).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All (${_allQuestions.length})',
                  selected: _filter == _Filter.all,
                  onTap: () => _onFilterChanged(_Filter.all),
                ),
                const SizedBox(width: 10),
                _FilterChip(
                  label: 'Bookmarked ($bookmarkedCount)',
                  selected: _filter == _Filter.bookmarked,
                  onTap: () => _onFilterChanged(_Filter.bookmarked),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text(
                    _filter == _Filter.bookmarked
                        ? 'No bookmarked questions yet.'
                        : 'No questions available yet for this state/language.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    if (item is _AdBreak) {
                      return const _BannerAdCard();
                    }
                    final questionItem = item as _QuestionItem;
                    return _QuestionCard(
                      number: questionItem.number,
                      question: questionItem.question,
                      lang: lang,
                      bookmarked: BookmarkStore.instance.isBookmarked(questionItem.question.id),
                      onBookmarkToggle: () => _onBookmarkToggled(questionItem.question.id),
                    );
                  },
                ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: colorScheme.surface.withOpacity(0.15),
      selectedColor: colorScheme.surface,
      labelStyle: TextStyle(
        color: selected ? colorScheme.primary : colorScheme.surface,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: colorScheme.surface.withOpacity(0.6)),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final int number;
  final QuestionModel question;
  final String lang;
  final bool bookmarked;
  final VoidCallback onBookmarkToggle;

  const _QuestionCard({
    required this.number,
    required this.question,
    required this.lang,
    required this.bookmarked,
    required this.onBookmarkToggle,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final options = q.optionsFor(widget.lang);
    final explanation = q.explanationText(widget.lang);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Q${widget.number}. ${q.questionText(widget.lang)}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                IconButton(
                  onPressed: widget.onBookmarkToggle,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    widget.bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: widget.bookmarked ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(options.length, (i) {
              final isCorrect = i == q.correctIndex;
              final highlight = _revealed && isCorrect;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      highlight ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: highlight ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        options[i],
                        style: TextStyle(
                          fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                          color: highlight ? Colors.green.shade700 : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _revealed = !_revealed),
                icon: Icon(_revealed ? Icons.visibility_off : Icons.visibility, size: 18),
                label: Text(_revealed ? 'Hide Answer' : 'Show Answer'),
              ),
            ),
            if (_revealed && explanation != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  explanation,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A single banner ad slot dropped into the question list. Loads its own
/// ad independently so a failure in one slot doesn't affect the others,
/// and collapses to nothing (no reserved blank space) if the ad fails
/// to load.
class _BannerAdCard extends StatefulWidget {
  const _BannerAdCard();

  @override
  State<_BannerAdCard> createState() => _BannerAdCardState();
}

class _BannerAdCardState extends State<_BannerAdCard> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final ad = BannerAd(
      // Replace with your real AdMob banner ad unit ID, e.g. via
      // AppConstants.bannerAdUnitId.
      adUnitId: AppConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 12),
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
