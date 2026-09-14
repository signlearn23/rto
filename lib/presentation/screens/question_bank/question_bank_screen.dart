import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/question_model.dart';
import '../../../data/models/sign_model.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../data/repositories/sign_repository.dart';
import '../../../data/services/bookmark_store.dart';
import '../../providers/app_state_provider.dart';

enum _Filter { all, bookmarked }

class _NumberedItem<T> {
  final int number;
  final T item;
  const _NumberedItem(this.number, this.item);
}

class _AdBreak {
  const _AdBreak();
}

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _questionRepo = QuestionRepository();
  final _signRepo = SignRepository();
  final _random = math.Random();

  List<QuestionModel> _allQuestions = [];
  List<SignModel> _allSigns = [];
  List<dynamic> _questionItems = [];
  List<dynamic> _signItems = [];

  bool _loadingQuestions = true;
  bool _loadingSigns = true;

  _Filter _questionFilter = _Filter.all;
  _Filter _signFilter = _Filter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuestions();
    _loadSigns();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _randomGap() => 4 + _random.nextInt(5);

  /// Interleaves ad breaks into a numbered list. Shared by both tabs.
  List<dynamic> _withAdBreaks<T>(List<T> list) {
    final items = <dynamic>[];
    var untilNextAd = _randomGap();
    for (var i = 0; i < list.length; i++) {
      items.add(_NumberedItem<T>(i + 1, list[i]));
      untilNextAd--;
      if (untilNextAd <= 0 && i != list.length - 1) {
        items.add(const _AdBreak());
        untilNextAd = _randomGap();
      }
    }
    return items;
  }

  Future<void> _loadQuestions() async {
    await BookmarkStore.instance.init();
    final appState = context.read<AppStateProvider>();
    final grouped = await _questionRepo.groupedByTopic(
      stateCode: appState.selectedState ?? 'tamilnadu',
      languageCode: appState.selectedLanguage ?? 'en',
    );
    if (!mounted) return;
    _allQuestions = grouped.values.expand((qs) => qs).toList();
    setState(() => _loadingQuestions = false);
    _rebuildQuestionItems();
  }

  Future<void> _loadSigns() async {
    await BookmarkStore.instance.init();
    final appState = context.read<AppStateProvider>();
    final grouped = await _signRepo.groupedByCategory(
      stateCode: appState.selectedState ?? 'tamilnadu',
    );
    if (!mounted) return;
    _allSigns = grouped.values.expand((s) => s).toList();
    setState(() => _loadingSigns = false);
    _rebuildSignItems();
  }

  List<QuestionModel> get _filteredQuestions {
    if (_questionFilter == _Filter.bookmarked) {
      return _allQuestions.where((q) => BookmarkStore.instance.isBookmarked(q.id)).toList();
    }
    return _allQuestions;
  }

  List<SignModel> get _filteredSigns {
    if (_signFilter == _Filter.bookmarked) {
      return _allSigns.where((s) => BookmarkStore.instance.isBookmarked(s.id)).toList();
    }
    return _allSigns;
  }

  void _rebuildQuestionItems() {
    setState(() => _questionItems = _withAdBreaks(_filteredQuestions));
  }

  void _rebuildSignItems() {
    setState(() => _signItems = _withAdBreaks(_filteredSigns));
  }

  void _onQuestionFilterChanged(_Filter filter) {
    if (filter == _questionFilter) return;
    _questionFilter = filter;
    _rebuildQuestionItems();
  }

  void _onSignFilterChanged(_Filter filter) {
    if (filter == _signFilter) return;
    _signFilter = filter;
    _rebuildSignItems();
  }

  Future<void> _onQuestionBookmarkToggled(String id) async {
    await BookmarkStore.instance.toggle(id);
    if (!mounted) return;
    if (_questionFilter == _Filter.bookmarked) {
      _rebuildQuestionItems();
    } else {
      setState(() {});
    }
  }

  Future<void> _onSignBookmarkToggled(String id) async {
    await BookmarkStore.instance.toggle(id);
    if (!mounted) return;
    if (_signFilter == _Filter.bookmarked) {
      _rebuildSignItems();
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Questions'),
            Tab(text: 'Traffic Signs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuestionsTab(),
          _buildSignsTab(),
        ],
      ),
    );
  }

  Widget _buildQuestionsTab() {
    final appState = context.watch<AppStateProvider>();
    final lang = appState.selectedLanguage ?? 'en';
    final bookmarkedCount =
        _allQuestions.where((q) => BookmarkStore.instance.isBookmarked(q.id)).length;

    if (_loadingQuestions) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              _FilterChip(
                label: 'All (${_allQuestions.length})',
                selected: _questionFilter == _Filter.all,
                onTap: () => _onQuestionFilterChanged(_Filter.all),
              ),
              const SizedBox(width: 10),
              _FilterChip(
                label: 'Bookmarked ($bookmarkedCount)',
                selected: _questionFilter == _Filter.bookmarked,
                onTap: () => _onQuestionFilterChanged(_Filter.bookmarked),
              ),
            ],
          ),
        ),
        Expanded(
          child: _questionItems.isEmpty
              ? Center(
                  child: Text(
                    _questionFilter == _Filter.bookmarked
                        ? 'No bookmarked questions yet.'
                        : 'No questions available yet for this state/language.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questionItems.length,
                  itemBuilder: (context, index) {
                    final item = _questionItems[index];
                    if (item is _AdBreak) return const _BannerAdCard();
                    final numbered = item as _NumberedItem<QuestionModel>;
                    return _QuestionCard(
                      number: numbered.number,
                      question: numbered.item,
                      lang: lang,
                      bookmarked: BookmarkStore.instance.isBookmarked(numbered.item.id),
                      onBookmarkToggle: () => _onQuestionBookmarkToggled(numbered.item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSignsTab() {
    final appState = context.watch<AppStateProvider>();
    final lang = appState.selectedLanguage ?? 'en';
    final bookmarkedCount =
        _allSigns.where((s) => BookmarkStore.instance.isBookmarked(s.id)).length;

    if (_loadingSigns) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              _FilterChip(
                label: 'All (${_allSigns.length})',
                selected: _signFilter == _Filter.all,
                onTap: () => _onSignFilterChanged(_Filter.all),
              ),
              const SizedBox(width: 10),
              _FilterChip(
                label: 'Bookmarked ($bookmarkedCount)',
                selected: _signFilter == _Filter.bookmarked,
                onTap: () => _onSignFilterChanged(_Filter.bookmarked),
              ),
            ],
          ),
        ),
        Expanded(
          child: _signItems.isEmpty
              ? Center(
                  child: Text(
                    _signFilter == _Filter.bookmarked
                        ? 'No bookmarked signs yet.'
                        : 'No traffic signs available yet for this state.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _signItems.length,
                  itemBuilder: (context, index) {
                    final item = _signItems[index];
                    if (item is _AdBreak) return const _BannerAdCard();
                    final numbered = item as _NumberedItem<SignModel>;
                    return _SignCard(
                      number: numbered.number,
                      sign: numbered.item,
                      lang: lang,
                      bookmarked: BookmarkStore.instance.isBookmarked(numbered.item.id),
                      onBookmarkToggle: () => _onSignBookmarkToggled(numbered.item.id),
                    );
                  },
                ),
        ),
      ],
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
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: colorScheme.outline.withOpacity(0.6)),
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  explanation,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Same quiz-card layout as _QuestionCard, but for a sign: the image is
/// always shown (a sign has no "question without image" mode).
class _SignCard extends StatefulWidget {
  final int number;
  final SignModel sign;
  final String lang;
  final bool bookmarked;
  final VoidCallback onBookmarkToggle;

  const _SignCard({
    required this.number,
    required this.sign,
    required this.lang,
    required this.bookmarked,
    required this.onBookmarkToggle,
  });

  @override
  State<_SignCard> createState() => _SignCardState();
}

class _SignCardState extends State<_SignCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.sign;
    final options = s.optionsFor(widget.lang);
    final explanation = s.explanationText(widget.lang);

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
                    'S${widget.number}. ${s.questionText(widget.lang)}',
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
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(s.image, height: 130, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(options.length, (i) {
              final isCorrect = i == s.correctIndex;
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  explanation,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
