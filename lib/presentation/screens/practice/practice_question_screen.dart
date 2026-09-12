import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/question_model.dart';
import '../../../data/repositories/question_repository.dart';
import '../../providers/app_state_provider.dart';

/// Untimed practice: answer, get instant feedback, move to next question.
class PracticeQuestionScreen extends StatefulWidget {
  final String topic;
  const PracticeQuestionScreen({super.key, required this.topic});

  @override
  State<PracticeQuestionScreen> createState() => _PracticeQuestionScreenState();
}

class _PracticeQuestionScreenState extends State<PracticeQuestionScreen> {
  final _repo = QuestionRepository();
  List<QuestionModel> _questions = [];
  int _index = 0;
  int? _selected;
  bool _loading = true;
  int _correct = 0;
  // QuestionModel now stores question/options/explanation per language
  // (Map<String,...>) instead of a flat String/List<String>, so we keep
  // track of the selected language and read through it everywhere below.
  String _lang = 'en';

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
      _lang = appState.selectedLanguage ?? 'en';
      _questions = grouped[widget.topic] ?? [];
      _loading = false;
    });
  }

  void _select(int i) {
    if (_selected != null) return;
    setState(() {
      _selected = i;
      if (i == _questions[_index].correctIndex) _correct++;
    });
  }

  void _next() {
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _selected = null;
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Practice Complete'),
          content: Text('You got $_correct / ${_questions.length} correct.'),
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
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.topic)),
        body: const Center(child: Text('No questions in this topic yet.')),
      );
    }
    final q = _questions[_index];
    final options = q.optionsFor(_lang);
    final explanation = q.explanationText(_lang);

    return Scaffold(
      appBar: AppBar(title: Text(widget.topic)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: (_index + 1) / _questions.length),
            const SizedBox(height: 8),
            Text('Question ${_index + 1} of ${_questions.length}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Text(q.questionText(_lang), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            ...List.generate(options.length, (i) {
              final isSelected = _selected == i;
              final isCorrect = i == q.correctIndex;
              Color? color;
              if (_selected != null) {
                if (isCorrect) {
                  color = Colors.green.withOpacity(0.15);
                } else if (isSelected) {
                  color = Colors.red.withOpacity(0.15);
                }
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => _select(i),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(options[i])),
                        if (_selected != null && isCorrect)
                          const Icon(Icons.check_circle, color: Colors.green),
                        if (_selected != null && isSelected && !isCorrect)
                          const Icon(Icons.cancel, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (_selected != null && explanation != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: Text('💡 $explanation', style: TextStyle(color: Colors.grey.shade700)),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected == null ? null : _next,
                child: Text(_index == _questions.length - 1 ? 'Finish' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
