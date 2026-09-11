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
    final color = passed ? AppColors.success : AppColors.danger;
    final percent = attempt.totalQuestions == 0
        ? 0.0
        : attempt.correctAnswers / attempt.totalQuestions;

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Result'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ---- Hero score card ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  passed ? 'PASSED' : 'NOT PASSED',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: color,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: percent,
                          strokeWidth: 12,
                          backgroundColor: color.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${attempt.correctAnswers}/${attempt.totalQuestions}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            '${(percent * 100).round()}%',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: color.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Icon(
                  passed ? Icons.emoji_events_rounded : Icons.replay_circle_filled_rounded,
                  size: 36,
                  color: color,
                ),
                const SizedBox(height: 8),
                Text(
                  passed ? 'You Passed!' : 'Not Passed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Passing score: ${AppConstants.passMarkOutOf10}/${AppConstants.questionsPerExam}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  'Time taken: ${attempt.timeTakenSeconds}s',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
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
