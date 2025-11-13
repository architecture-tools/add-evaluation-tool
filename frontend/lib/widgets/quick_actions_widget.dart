import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({
    super.key,
    this.onUpload,
    this.onEvaluateMatrix,
    this.onCompare,
    this.onExport,
    this.onAiInsights,
  });

  final VoidCallback? onUpload;
  final VoidCallback? onEvaluateMatrix;
  final VoidCallback? onCompare;
  final VoidCallback? onExport;
  final VoidCallback? onAiInsights;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Common tasks',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _ActionButton(
              icon: Icons.cloud_upload,
              label: 'Upload Diagram',
              description: 'Add new PlantUML file',
              onPressed: onUpload ?? () => _showWipSnack(context),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.grid_view,
              label: 'Evaluate Matrix',
              description: 'Score components',
              onPressed: onEvaluateMatrix ?? () => _showWipSnack(context),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.compare_arrows,
              label: 'Compare Versions',
              description: 'View differences',
              onPressed: onCompare ?? () => _showWipSnack(context),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.description,
              label: 'Export Report',
              description: 'Generate PDF/Excel',
              onPressed: onExport ?? () => _showWipSnack(context),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAiInsights ?? () => _showWipSnack(context),
                icon: const Icon(Icons.lightbulb_outline, size: 18),
                label: const Text('AI Insights (Beta)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWipSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This action will be available soon.')),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

