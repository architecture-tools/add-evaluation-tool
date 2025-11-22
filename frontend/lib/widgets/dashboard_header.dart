import 'dart:async';
import 'package:flutter/material.dart';
import '../services/health_service.dart';
import '../theme/app_theme.dart';

typedef UploadCallback = Future<void> Function(BuildContext context);

class DashboardHeader extends StatefulWidget {
  final String projectName;
  final String version;
  final UploadCallback onUpload;

  const DashboardHeader({
    super.key,
    required this.projectName,
    required this.version,
    required this.onUpload,
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
                Text(
                  '${widget.projectName} - Version ${widget.version}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Search, notifications, upload button
          Row(
            children: [
              // Search
              Container(
                width: 300,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search,
                        size: 20, color: AppTheme.textSecondary),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),

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

              // Notifications
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 24),
                    color: AppTheme.textSecondary,
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),

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
