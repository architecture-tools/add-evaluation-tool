import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/mock_models.dart';

class VersionTimelineWidget extends StatelessWidget {
  const VersionTimelineWidget({super.key, required this.timeline});

  final List<VersionInfo> timeline;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Version Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Evolution over time',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (timeline.isEmpty)
              const Text(
                'Timeline will appear after the first diagram is processed.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              )
            else
              ...timeline.asMap().entries.map((entry) {
                final index = entry.key;
                final version = entry.value;
                final isLast = index == timeline.length - 1;
                return _VersionItem(
                  version: version.version,
                  timeAgo: version.timeAgo,
                  description: version.description,
                  changes: version.changes,
                  score: version.score,
                  trend: version.trend,
                  showLine: !isLast,
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _VersionItem extends StatelessWidget {
  final String version;
  final String timeAgo;
  final String description;
  final String changes;
  final double score;
  final VersionTrend? trend;
  final bool showLine;

  const _VersionItem({
    required this.version,
    required this.timeAgo,
    required this.description,
    required this.changes,
    required this.score,
    this.trend,
    this.showLine = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryPurple, width: 2),
              ),
              child: trend == VersionTrend.down
                  ? const Icon(
                      Icons.arrow_downward,
                      size: 16,
                      color: AppTheme.primaryPurple,
                    )
                  : const Icon(
                      Icons.arrow_upward,
                      size: 16,
                      color: AppTheme.primaryPurple,
                    ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 60,
                color: AppTheme.borderColor,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),
        
        // Version info
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: showLine ? 20 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      version,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      changes,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Text(' • ', style: TextStyle(color: AppTheme.textSecondary)),
                    Text(
                      'Score: $score',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

