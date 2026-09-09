import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/question_repository.dart';
import '../../providers/app_state_provider.dart';
import 'practice_question_screen.dart';

/// Lets the user pick a topic before entering untimed Practice Mode.
class PracticeTopicScreen extends StatefulWidget {
  const PracticeTopicScreen({super.key});

  @override
  State<PracticeTopicScreen> createState() => _PracticeTopicScreenState();
}

class _PracticeTopicScreenState extends State<PracticeTopicScreen> {
  final _repo = QuestionRepository();
  Map<String, int> _topicCounts = {};
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
      _topicCounts = grouped.map((k, v) => MapEntry(k, v.length));
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice Mode')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Pick a topic — no timer, learn at your own pace.',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                ..._topicCounts.entries.map((e) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.fitness_center_rounded, color: Colors.teal),
                        title: Text(e.key),
                        subtitle: Text('${e.value} questions'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => PracticeQuestionScreen(topic: e.key),
                        )),
                      ),
                    )),
              ],
            ),
    );
  }
}
