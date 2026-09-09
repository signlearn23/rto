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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Question Bank')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _grouped.isEmpty
              ? const Center(child: Text('No questions available yet for this state/language.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: _grouped.entries.map((entry) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${entry.value.length} questions'),
                        children: entry.value
                            .map((q) => _QuestionTile(question: q))
                            .toList(),
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}

class _QuestionTile extends StatefulWidget {
  final QuestionModel question;
  const _QuestionTile({required this.question});

  @override
  State<_QuestionTile> createState() => _QuestionTileState();
}

class _QuestionTileState extends State<_QuestionTile> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q.question, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...List.generate(q.options.length, (i) {
            final isCorrect = i == q.correctIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(
                    _revealed && isCorrect ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                    color: _revealed && isCorrect ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(q.options[i])),
                ],
              ),
            );
          }),
          TextButton(
            onPressed: () => setState(() => _revealed = !_revealed),
            child: Text(_revealed ? 'Hide Answer' : 'Show Answer'),
          ),
          if (_revealed && q.explanation != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Explanation: ${q.explanation}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ),
          const Divider(),
        ],
      ),
    );
  }
}
