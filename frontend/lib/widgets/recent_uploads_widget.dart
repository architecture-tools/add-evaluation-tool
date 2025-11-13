import 'package:flutter/material.dart';
import '../network/src/api.dart';
import '../theme/app_theme.dart';
import '../utils/date_time_utils.dart';

class RecentUploadsWidget extends StatelessWidget {
  const RecentUploadsWidget({
    super.key,
    required this.diagrams,
    required this.onRefresh,
    required this.onRetryParse,
    this.processingDiagramId,
    this.isRefreshing = false,
  });

  final List<DiagramResponse> diagrams;
  final VoidCallback onRefresh;
  final ValueChanged<String> onRetryParse;
  final String? processingDiagramId;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final uploads = diagrams.take(6).toList(growable: false);

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
                      'Recent Uploads',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Latest architecture diagrams from the backend',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Refresh list',
                      onPressed: isRefreshing ? null : onRefresh,
                      icon: isRefreshing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                    ),
                    TextButton(
                      onPressed: diagrams.isEmpty ? null : onRefresh,
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (uploads.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                child: Text(
                  'No diagrams uploaded yet. Upload your first PlantUML file to get started.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...uploads.asMap().entries.map((entry) {
                final index = entry.key;
                final upload = entry.value;
                return Column(
                  children: [
                    _UploadItem(
                      diagram: upload,
                      status: _mapStatus(upload.status),
                      timeAgo: formatRelativeTime(upload.uploadedAt),
                      source: upload.sourceUrl,
                      parsedAt: upload.parsedAt,
                      isRetrying: processingDiagramId == upload.id,
                      onRetry: upload.status == DiagramStatus.failed
                          ? () => onRetryParse(upload.id)
                          : null,
                    ),
                    if (index < uploads.length - 1) const Divider(height: 32),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  UploadStatus _mapStatus(DiagramStatus status) {
    switch (status) {
      case DiagramStatus.parsed:
      case DiagramStatus.analysisReady:
        return UploadStatus.parsed;
      case DiagramStatus.uploaded:
        return UploadStatus.processing;
      case DiagramStatus.failed:
        return UploadStatus.error;
    }
    return UploadStatus.processing;
  }
}

enum UploadStatus { parsed, processing, error }

class _UploadItem extends StatelessWidget {
  const _UploadItem({
    required this.diagram,
    required this.status,
    required this.timeAgo,
    required this.source,
    this.parsedAt,
    this.onRetry,
    this.isRetrying = false,
  });

  final DiagramResponse diagram;
  final UploadStatus status;
  final String timeAgo;
  final String source;
  final DateTime? parsedAt;
  final VoidCallback? onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Status icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        // File info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diagram.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Uploaded $timeAgo',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                source,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (parsedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Parsed ${formatRelativeTime(parsedAt!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.green,
                  ),
                ),
              ],
              if (status == UploadStatus.error) ...[
                const SizedBox(height: 4),
                const Text(
                  'Parsing failed. Retry to reprocess the diagram.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.red,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Status badge / actions
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (status == UploadStatus.error && onRetry != null)
                TextButton(
                  onPressed: isRetrying ? null : onRetry,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: isRetrying
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Retry',
                          style: TextStyle(fontSize: 11, color: AppTheme.red),
                        ),
                )
              else
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.more_vert, size: 20),
          color: AppTheme.textSecondary,
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (context) => _UploadActionsSheet(diagram: diagram),
            );
          },
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case UploadStatus.parsed:
        return AppTheme.green;
      case UploadStatus.processing:
        return AppTheme.yellow;
      case UploadStatus.error:
        return AppTheme.red;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case UploadStatus.parsed:
        return Icons.check_circle;
      case UploadStatus.processing:
        return Icons.hourglass_empty;
      case UploadStatus.error:
        return Icons.error;
    }
  }

  String _getStatusText() {
    switch (status) {
      case UploadStatus.parsed:
        return parsedAt != null ? 'Parsed' : 'Processed';
      case UploadStatus.processing:
        return 'Processing';
      case UploadStatus.error:
        return 'Error';
    }
  }
}

class _UploadActionsSheet extends StatelessWidget {
  const _UploadActionsSheet({required this.diagram});

  final DiagramResponse diagram;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              diagram.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Open source URL'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening source URL is not implemented yet.'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('View details'),
              subtitle: Text('Uploaded ${formatRelativeTime(diagram.uploadedAt)}'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

