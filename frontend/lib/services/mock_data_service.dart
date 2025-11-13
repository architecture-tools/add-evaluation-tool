import 'package:flutter/material.dart';
import '../models/mock_models.dart';
import '../models/nfr_matrix.dart';
import '../theme/app_theme.dart';

/// Mock data service for widgets that don't yet have OpenAPI support.
class MockDataService {
  static List<NFRMetric> getNFRMetrics() {
    return [
      NFRMetric('Performance', 8.5, AppTheme.blue),
      NFRMetric('Security', 9.2, AppTheme.green),
      NFRMetric('Usability', 7.8, AppTheme.primaryPurple),
      NFRMetric('Maintainability', 6.9, AppTheme.orange),
      NFRMetric('Scalability', 5.8, AppTheme.red),
      NFRMetric('Reliability', 8.1, const Color(0xFF1E40AF)),
    ];
  }

  static NfrMatrixData getDefaultMatrix() {
    const components = [
      'API Gateway',
      'Auth Service',
      'Payment',
      'Order Mgmt',
      'Database',
    ];

    return NfrMatrixData(
      version: 'v2.3.1',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      components: components,
      rows: [
        NfrMatrixRow(
          nfr: 'Usability',
          color: AppTheme.green,
          scores: const {
            'API Gateway': 1,
            'Auth Service': 1,
            'Payment': 0,
            'Order Mgmt': 1,
            'Database': 0,
          },
        ),
        NfrMatrixRow(
          nfr: 'Performance',
          color: AppTheme.orange,
          scores: const {
            'API Gateway': 1,
            'Auth Service': 0,
            'Payment': 0,
            'Order Mgmt': 1,
            'Database': 1,
          },
        ),
        NfrMatrixRow(
          nfr: 'Security',
          color: AppTheme.red,
          scores: const {
            'API Gateway': 1,
            'Auth Service': 1,
            'Payment': 0,
            'Order Mgmt': 0,
            'Database': 1,
          },
        ),
        NfrMatrixRow(
          nfr: 'Maintainability',
          color: AppTheme.primaryPurple,
          scores: const {
            'API Gateway': 0,
            'Auth Service': 0,
            'Payment': 0,
            'Order Mgmt': 0,
            'Database': 0,
          },
        ),
        NfrMatrixRow(
          nfr: 'Reliability',
          color: AppTheme.blue,
          scores: const {
            'API Gateway': 1,
            'Auth Service': 1,
            'Payment': 0,
            'Order Mgmt': 1,
            'Database': 1,
          },
        ),
      ],
    );
  }
}

