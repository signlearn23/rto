import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/exam_attempt_model.dart';
import '../../../data/repositories/result_repository.dart';
import '../exam/exam_result_screen.dart';

class ResultHistoryScreen extends StatefulWidget {
  const ResultHistoryScreen({super.key});

  @override
  State<ResultHistoryScreen> createState() => _ResultHistoryScreenState();
}

class _ResultHistoryScreenState extends State<ResultHistoryScreen> {
  final _repo = ResultRepository();
  late List<ExamAttempt> _attempts;

  @override
  void initState() {
    super.initState();
    _attempts = _repo.getAllAttempts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result History')),
      body: _attempts.isEmpty
          ? const Center(child: Text('No exam attempts yet. Take an exam to see results here.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _attempts.length,
              itemBuilder: (context, index) {
                final a = _attempts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: a.passed
                          ? AppColors.success.withOpacity(0.15)
                          : AppColors.danger.withOpacity(0.15),
                      child: Icon(
                        a.passed ? Icons.check : Icons.close,
                        color: a.passed ? AppColors.success : AppColors.danger,
                      ),
                    ),
                    title: Text('${a.correctAnswers}/${a.totalQuestions} — ${a.passed ? "Pass" : "Fail"}'),
                    subtitle: Text(
                        '${a.dateTime.day}/${a.dateTime.month}/${a.dateTime.year}  •  ${a.timeTakenSeconds}s'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => ExamResultScreen(attempt: a))),
                  ),
                );
              },
            ),
    );
  }
}
