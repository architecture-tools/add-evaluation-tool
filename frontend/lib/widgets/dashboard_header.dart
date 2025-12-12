import 'dart:async';
import 'package:flutter/material.dart';
import '../services/health_service.dart';
import '../theme/app_theme.dart';

typedef UploadCallback = Future<void> Function(BuildContext context);
typedef LogoutCallback = Future<void> Function();

class DashboardHeader extends StatefulWidget {
  final UploadCallback onUpload;
  final LogoutCallback? onLogout;
  final String? userEmail;

  const DashboardHeader({
    super.key,
    required this.onUpload,
    this.onLogout,
    this.userEmail,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  final HealthService _healthService = HealthService();
  HealthStatus? _healthStatus;
  Timer? _healthCheckTimer;

  @override
  void initState() {
    super.initState();
    _checkHealth();
    // Check health every 30 seconds
    _healthCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkHealth(),
    );
  }

  @override
  void dispose() {
    _healthCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkHealth() async {
    final status = await _healthService.checkHealth();
    if (mounted) {
      setState(() {
        _healthStatus = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          // Logo and title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.architecture,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Architecture Evaluator',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 48),

          // Main title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Architecture Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Health status and upload button
          Row(
            children: [
              // Health status indicator
              Tooltip(
                message: _healthStatus?.isHealthy == true
                    ? 'Backend is healthy'
                    : 'Backend connection issue',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (_healthStatus?.isHealthy ?? false)
                        ? AppTheme.green.withOpacity(0.1)
                        : AppTheme.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (_healthStatus?.isHealthy ?? false)
                          ? AppTheme.green
                          : AppTheme.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: (_healthStatus?.isHealthy ?? false)
                              ? AppTheme.green
                              : AppTheme.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _healthStatus?.isHealthy == true ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: (_healthStatus?.isHealthy ?? false)
                              ? AppTheme.green
                              : AppTheme.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // User email and logout
              if (widget.userEmail != null) ...[
                Text(
                  widget.userEmail!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout, size: 20),
                  tooltip: 'Logout',
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
              ],

              // Upload button
              ElevatedButton.icon(
                onPressed: () => widget.onUpload(context),
                icon: const Icon(Icons.upload, size: 18),
                label: const Text('Upload New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
