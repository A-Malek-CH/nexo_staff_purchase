import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/repositories/task_repository.dart';
import '../../providers/task_provider.dart';

class TaskDetailsScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailsScreen({
    super.key,
    required this.taskId,
  });

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  bool _isMarkingDone = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taskDetails),
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
              const SizedBox(height: AppTheme.spacingM),
              Text(error.toString(), style: AppTheme.bodyMedium),
              const SizedBox(height: AppTheme.spacingM),
              ElevatedButton(
                onPressed: () => ref.invalidate(taskDetailProvider(widget.taskId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (task) => SingleChildScrollView(
          padding: AppTheme.paddingM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Header Card
              Card(
                child: Padding(
                  padding: AppTheme.paddingM,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              task.taskNumber,
                              style: AppTheme.headingMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(task.status),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildInfoRow(l10n.taskStatus, task.status.toUpperCase()),
                      if (task.deadline != null)
                        _buildInfoRow(l10n.dueDate, DateHelper.formatDeadline(task.deadline!)),
                      if (task.staffId != null)
                        _buildInfoRow('Staff', task.staffId!.fullname),
                      _buildInfoRow('Created', DateHelper.formatDate(task.createdAt)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),

              // Description Card
              if (task.description != null && task.description!.isNotEmpty)
                Card(
                  child: Padding(
                    padding: AppTheme.paddingM,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description', style: AppTheme.headingSmall),
                        const SizedBox(height: AppTheme.spacingS),
                        Text(task.description!, style: AppTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              if (task.description != null && task.description!.isNotEmpty)
                const SizedBox(height: AppTheme.spacingM),

              // Mark as Done Button
              if (task.status == AppConstants.taskStatusPending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isMarkingDone ? null : () => _markAsDone(context, l10n),
                    icon: _isMarkingDone
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(_isMarkingDone ? l10n.markingAsDone : l10n.markAsDone),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              const SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markAsDone(BuildContext context, AppLocalizations l10n) async {
    setState(() => _isMarkingDone = true);
    try {
      await ref.read(taskRepositoryProvider).updateTaskStatus(
        widget.taskId,
        AppConstants.taskStatusCompleted,
      );
      // Refresh task detail and tasks list
      ref.invalidate(taskDetailProvider(widget.taskId));
      if (mounted) {
        ref.read(tasksProvider.notifier).refreshTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.taskMarkedDone),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isMarkingDone = false);
    }
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTheme.bodySmall.copyWith(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.mediumGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.taskStatusCompleted:
        return AppTheme.successGreen;
      case AppConstants.taskStatusInProgress:
        return AppTheme.primaryOrange;
      case AppConstants.taskStatusCancelled:
        return AppTheme.errorRed;
      default:
        return AppTheme.mediumGrey;
    }
  }
}
