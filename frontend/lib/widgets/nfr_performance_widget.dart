import 'package:flutter/material.dart';
import '../network/src/api.dart';
import '../services/nfr_repository.dart';
import '../theme/app_theme.dart';
import '../models/mock_models.dart';

class NFRPerformanceWidget extends StatefulWidget {
  const NFRPerformanceWidget({
    super.key,
    required this.metrics,
    this.nfrs = const [],
    this.onRefresh,
  });

  final List<NFRMetric> metrics;
  final List<NFRResponse> nfrs;
  final VoidCallback? onRefresh;

  @override
  State<NFRPerformanceWidget> createState() => _NFRPerformanceWidgetState();
}

class _NFRPerformanceWidgetState extends State<NFRPerformanceWidget> {
  final NFRRepository _nfrRepository = NFRRepository();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NFR Performance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Latest evaluation metrics',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      tooltip: 'Add NFR',
                      onPressed: _showCreateNFRDialog,
                      color: AppTheme.primaryPurple,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View Matrix'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.metrics.isEmpty)
              const Text(
                'No NFR metrics available yet.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              )
            else ...[
              ...widget.metrics.map((nfr) {
                // Find corresponding NFRResponse if available
                final nfrResponse = widget.nfrs.firstWhere(
                  (n) => n.name == nfr.name,
                  orElse: () => NFRResponse(
                    id: '',
                    name: nfr.name,
                    createdAt: DateTime.now(),
                  ),
                );
                return _NFRItem(
                  name: nfr.name,
                  score: nfr.score,
                  color: nfr.color,
                  nfrId: nfrResponse.id.isEmpty ? null : nfrResponse.id,
                  onDelete: nfrResponse.id.isEmpty
                      ? null
                      : () => _deleteNFR(nfrResponse.id, nfrResponse.name),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateNFRDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Non-Functional Requirement'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    hintText: 'e.g., Performance, Security, Scalability',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.length > 255) {
                      return 'Name must be 255 characters or less';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Describe the NFR requirement',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        await _nfrRepository.createNFR(
          name: nameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'NFR "${nameController.text.trim()}" created successfully'),
              backgroundColor: AppTheme.green,
            ),
          );
          widget.onRefresh?.call();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create NFR: $e'),
              backgroundColor: AppTheme.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteNFR(String nfrId, String nfrName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete NFR'),
        content: Text('Are you sure you want to delete "$nfrName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _nfrRepository.deleteNFR(nfrId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('NFR "$nfrName" deleted successfully'),
              backgroundColor: AppTheme.green,
            ),
          );
          widget.onRefresh?.call();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete NFR: $e'),
              backgroundColor: AppTheme.red,
            ),
          );
        }
      }
    }
  }
}

class _NFRItem extends StatelessWidget {
  final String name;
  final double score;
  final Color color;
  final String? nfrId;
  final VoidCallback? onDelete;

  const _NFRItem({
    required this.name,
    required this.score,
    required this.color,
    this.nfrId,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                '$score/10',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (nfrId != null && onDelete != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppTheme.textSecondary,
                  onPressed: onDelete,
                  tooltip: 'Delete NFR',
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 10,
              minHeight: 8,
              backgroundColor: AppTheme.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
