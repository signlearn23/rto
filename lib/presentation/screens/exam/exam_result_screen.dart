import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/exam_attempt_model.dart';
import '../home/home_screen.dart';
import 'exam_screen.dart';

class ExamResultScreen extends StatelessWidget {
  final ExamAttempt attempt;
  const ExamResultScreen({super.key, required this.attempt});

  @override
  Widget build(BuildContext context) {
    final passed = attempt.passed;
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Result'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  passed ? Icons.emoji_events_rounded : Icons.replay_circle_filled_rounded,
                  size: 72,
                  color: passed ? AppColors.success : AppColors.danger,
                ),
                const SizedBox(height: 12),
                Text(
                  passed ? 'You Passed!' : 'Not Passed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: passed ? AppColors.success : AppColors.danger,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${attempt.correctAnswers} / ${attempt.totalQuestions} correct '
                  '(need ${AppConstants.passMarkOutOf10}/${AppConstants.questionsPerExam} to pass)',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text('Time taken: ${attempt.timeTakenSeconds}s',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Review Answers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...attempt.questionResults.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          r.isCorrect ? Icons.check_circle : Icons.cancel,
                          color: r.isCorrect ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Q${i + 1}. ${r.questionText}',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      r.timedOut
                          ? '⏱ Time out — Correct answer: ${r.options[r.correctIndex]}'
                          : r.isCorrect
                              ? 'Your answer: ${r.options[r.selectedIndex!]}'
                              : 'Your answer: ${r.options[r.selectedIndex!]}  •  Correct: ${r.options[r.correctIndex]}',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  ),
                  child: const Text('Home'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ExamScreen()),
                  ),
                  child: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
