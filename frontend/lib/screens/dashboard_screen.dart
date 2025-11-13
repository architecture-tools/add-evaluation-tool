import 'dart:async';

import 'package:flutter/material.dart';

import '../services/dashboard_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_time_utils.dart';
import '../widgets/kpi_card.dart';
import '../widgets/nfr_evaluation_matrix_widget.dart';
import '../widgets/nfr_performance_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/version_timeline_widget.dart';

typedef UploadHandler = Future<void> Function(BuildContext context);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.onUpload});

  final UploadHandler onUpload;

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  late Future<DashboardViewData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _dashboardService.loadDashboard();
  }

  Future<void> refresh() async {
    await _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture = _dashboardService.loadDashboard();
    });

    try {
      await _dashboardFuture;
    } catch (_) {
      // handled by UI state
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardViewData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error);
        }

        if (!snapshot.hasData) {
          return _buildErrorState('No data available');
        }

        final data = snapshot.data!;
        final metrics = data.metrics;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Cards Row
                Row(
                  children: [
                    Expanded(
                      child: KPICard(
                        title: 'Total Diagrams',
                        value: metrics.totalDiagrams.toString(),
                        subtitle: metrics.lastUploadAt != null
                            ? 'Last upload: ${formatRelativeTime(metrics.lastUploadAt!)}'
                            : 'No uploads yet',
                        icon: Icons.account_tree,
                        iconColor: AppTheme.blue,
                        change: '+${metrics.totalDiagrams}',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: KPICard(
                        title: 'Parsed / Ready',
                        value: metrics.parsedCount.toString(),
                        subtitle: 'Successfully processed diagrams',
                        icon: Icons.check_circle,
                        iconColor: AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: KPICard(
                        title: 'Awaiting Parsing',
                        value: metrics.pendingCount.toString(),
                        subtitle: 'Queued for processing',
                        icon: Icons.schedule,
                        iconColor: AppTheme.yellow,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: KPICard(
                        title: 'Failed',
                        value: metrics.failedCount.toString(),
                        subtitle: 'Needs attention',
                        icon: Icons.warning,
                        iconColor: AppTheme.red,
                        badge:
                            metrics.failedCount > 0 ? 'Action required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // NFR Evaluation Matrix
                NfrEvaluationMatrixWidget(data: data.matrix),
                const SizedBox(height: 24),

                // Bottom Layout: Quick actions, NFR performance, version timeline
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          QuickActionsWidget(
                            onUpload: () {
                              unawaited(widget.onUpload(context));
                            },
                            onEvaluateMatrix: () =>
                                _showComingSoon('Evaluate Matrix'),
                            onCompare: () =>
                                _showComingSoon('Compare Versions'),
                            onExport: () => _showComingSoon('Export Report'),
                            onAiInsights: () => _showComingSoon('AI Insights'),
                          ),
                          const SizedBox(height: 16),
                          NFRPerformanceWidget(metrics: data.nfrMetrics),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: VersionTimelineWidget(timeline: data.timeline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Unable to load dashboard data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '$error',
            style: TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$featureName is coming soon.')),
    );
  }
}
