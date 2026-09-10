import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/question_model.dart';
import '../../../data/repositories/question_repository.dart';
import '../../providers/app_state_provider.dart';

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  final _repo = QuestionRepository();
  Map<String, List<QuestionModel>> _grouped = {};
  bool _loading = true;

  static const String _allTopics = 'All Topics';
  String _selectedTopic = _allTopics;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final appState = context.read<AppStateProvider>();
    final grouped = await _repo.groupedByTopic(
      stateCode: appState.selectedState ?? 'tamilnadu',
      languageCode: appState.selectedLanguage ?? 'en',
    );
    setState(() {
      _grouped = grouped;
      _loading = false;
    });
  }

  List<QuestionModel> get _visibleQuestions {
    if (_selectedTopic == _allTopics) {
      return _grouped.values.expand((qs) => qs).toList();
    }
    return _grouped[_selectedTopic] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final topics = [_allTopics, ..._grouped.keys];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank'),
        actions: [
          if (!_loading && _grouped.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTopic,
                    dropdownColor: Theme.of(context).appBarTheme.backgroundColor,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    items: topics.map((topic) {
                      final count = topic == _allTopics
                          ? _grouped.values.fold<int>(0, (sum, qs) => sum + qs.length)
                          : _grouped[topic]!.length;
                      return DropdownMenuItem(
                        value: topic,
                        child: Text('$topic ($count)'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedTopic = value);
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _grouped.isEmpty
              ? const Center(child: Text('No questions available yet for this state/language.'))
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        '${_visibleQuestions.length} question${_visibleQuestions.length == 1 ? '' : 's'}'
                        '${_selectedTopic == _allTopics ? '' : ' • $_selectedTopic'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _visibleQuestions.length,
                        itemBuilder: (context, index) {
                          final q = _visibleQuestions[index];
                          return _QuestionCard(index: index + 1, question: q);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final int index;
  final QuestionModel question;
  const _QuestionCard({required this.index, required this.question});

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q${widget.index}. ${q.question}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 10),
            ...List.generate(q.options.length, (i) {
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
                        q.options[i],
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
            if (_revealed && q.explanation != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  q.explanation!,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
