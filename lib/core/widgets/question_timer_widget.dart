import 'dart:async';
import 'package:flutter/material.dart';

/// Circular countdown ring for the per-question timer in Exam Mode.
class QuestionTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onTimeout;
  final ValueChanged<int>? onTick;
  final Key resetKey; // change this key to restart the timer for a new question

  const QuestionTimer({
    super.key,
    required this.seconds,
    required this.onTimeout,
    required this.resetKey,
    this.onTick,
  });

  @override
  State<QuestionTimer> createState() => _QuestionTimerState();
}

class _QuestionTimerState extends State<QuestionTimer> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant QuestionTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetKey != widget.resetKey) {
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    _remaining = widget.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _remaining--;
      });
      widget.onTick?.call(_remaining);
      if (_remaining <= 0) {
        t.cancel();
        widget.onTimeout();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remaining / widget.seconds;
    final isUrgent = _remaining <= 10;
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0, 1),
            strokeWidth: 4,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(isUrgent ? Colors.red : Colors.green),
          ),
          Text(
            '$_remaining',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isUrgent ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}
