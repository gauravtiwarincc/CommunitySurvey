import 'dart:async';
import 'package:flutter/material.dart';

class SurveyTimerWidget extends StatefulWidget {
  final DateTime expiresAt;
  final TextStyle? style;
  final bool compact;

  const SurveyTimerWidget({
    super.key,
    required this.expiresAt,
    this.style,
    this.compact = false,
  });

  @override
  State<SurveyTimerWidget> createState() => _SurveyTimerWidgetState();
}

class _SurveyTimerWidgetState extends State<SurveyTimerWidget> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _calculateRemaining();
        });
      }
    });
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    _remaining = widget.expiresAt.difference(now);
    if (_remaining.isNegative) {
      _remaining = Duration.zero;
      _timer?.cancel();
    }
  }

  @override
  void didUpdateWidget(covariant SurveyTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expiresAt != widget.expiresAt) {
      _calculateRemaining();
      _timer?.cancel();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return 'Expired';
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final text = _formatDuration(_remaining);
    final isExpired = _remaining == Duration.zero;

    if (widget.compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isExpired ? Colors.red.shade50 : Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isExpired ? Colors.red.shade200 : Colors.amber.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 13,
              color: isExpired ? Colors.red.shade700 : Colors.amber.shade800,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isExpired ? Colors.red.shade700 : Colors.amber.shade800,
              ),
            ),
          ],
        ),
      );
    }

    // Large banner styled timer for details page
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isExpired ? Colors.red.shade200 : Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.alarm,
            color: isExpired ? Colors.red.shade700 : Colors.amber.shade800,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExpired ? 'Survey Expired' : 'Time Remaining to Submit',
                  style: TextStyle(
                    fontSize: 12,
                    color: isExpired ? Colors.red.shade700 : Colors.amber.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Submit before the timer ends to receive your reward points.',
                  style: TextStyle(fontSize: 10, color: Colors.white54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isExpired ? Colors.red.shade700 : Colors.amber.shade800,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
