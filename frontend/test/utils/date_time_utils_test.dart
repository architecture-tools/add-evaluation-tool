import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/utils/date_time_utils.dart';

void main() {
  group('formatRelativeTime', () {
    test('returns "just now" for very recent times', () {
      final now = DateTime.now();
      final result = formatRelativeTime(now);
      expect(result, 'just now');
    });

    test('returns seconds ago for times between 45 seconds and 1 minute', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(seconds: 50));
      final result = formatRelativeTime(past);
      expect(result, '50s ago');
    });

    test('returns minutes ago for times less than 1 hour', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(minutes: 15));
      final result = formatRelativeTime(past);
      expect(result, '15m ago');
    });

    test('returns hours ago for times less than 24 hours', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(hours: 5));
      final result = formatRelativeTime(past);
      expect(result, '5h ago');
    });

    test('returns days ago for times less than 7 days', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(days: 3));
      final result = formatRelativeTime(past);
      expect(result, '3d ago');
    });

    test('returns weeks ago for times less than 30 days', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(days: 14));
      final result = formatRelativeTime(past);
      expect(result, '2w ago');
    });

    test('returns months ago for times less than 365 days', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(days: 60));
      final result = formatRelativeTime(past);
      expect(result, '2mo ago');
    });

    test('returns years ago for times more than 365 days', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(days: 400));
      final result = formatRelativeTime(past);
      expect(result, '1y ago');
    });

    test('handles multiple years correctly', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(days: 800));
      final result = formatRelativeTime(past);
      expect(result, '2y ago');
    });

    test('returns "just now" for times less than 45 seconds', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(seconds: 30));
      final result = formatRelativeTime(past);
      expect(result, 'just now');
    });

    test('handles edge case of exactly 45 seconds', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(seconds: 45));
      final result = formatRelativeTime(past);
      // Exactly 45 seconds is NOT < 45, so it should return "45s ago"
      expect(result, '45s ago');
    });
  });
}
