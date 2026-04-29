import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_helper.dart';
import '../../providers/task_provider.dart';
import '../../widgets/app_bottom_nav.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tasksProvider.notifier).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                if (value == 'clear') {
                  _selectedStatus = null;
                  ref.read(tasksProvider.notifier).clearFilters();
                } else if (value.startsWith('status:')) {
                  _selectedStatus = value.split(':')[1];
                  ref.read(tasksProvider.notifier).loadTasks(status: _selectedStatus);
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear Filters'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                enabled: false,
                child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              PopupMenuItem(
                value: 'status:${AppConstants.taskStatusPending}',
                child: const Text('Pending'),
              ),
              PopupMenuItem(
                value: 'status:${AppConstants.taskStatusInProgress}',
                child: const Text('In Progress'),
              ),
              PopupMenuItem(
                value: 'status:${AppConstants.taskStatusCompleted}',
                child: const Text('Completed'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(tasksProvider.notifier).refreshTasks(),
        child: tasksState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : tasksState.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
                        const SizedBox(height: AppTheme.spacingM),
                        Text(tasksState.error!, style: AppTheme.bodyMedium),
                        const SizedBox(height: AppTheme.spacingM),
                        ElevatedButton(
                          onPressed: () => ref.read(tasksProvider.notifier).refreshTasks(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : tasksState.tasks.isEmpty
                    ? const Center(
                        child: Text('No tasks found', style: AppTheme.bodyMedium),
                      )
                    : ListView.builder(
                        padding: AppTheme.paddingM,
                        itemCount: tasksState.tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasksState.tasks[index];
                          final isOverdue = task.deadline != null &&
                              DateHelper.isOverdue(task.deadline!) &&
                              task.status != AppConstants.taskStatusCompleted;

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(task.status).withOpacity(0.2),
                                child: Icon(
                                  _getStatusIcon(task.status),
                                  color: _getStatusColor(task.status),
                                ),
                              ),
                              title: Text(
                                task.taskNumber,
                                style: AppTheme.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  if (task.deadline != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: isOverdue ? AppTheme.errorRed : AppTheme.mediumGrey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateHelper.formatDeadline(task.deadline!),
                                          style: AppTheme.bodySmall.copyWith(
                                            color: isOverdue ? AppTheme.errorRed : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 4),
                                  _StatusChip(
                                    label: task.status.toUpperCase(),
                                    color: _getStatusColor(task.status),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push('/tasks/${task.id}'),
                            ),
                          );
                        },
                      ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case AppConstants.taskStatusCompleted:
        return Icons.check_circle;
      case AppConstants.taskStatusInProgress:
        return Icons.pending;
      case AppConstants.taskStatusCancelled:
        return Icons.cancel;
      default:
        return Icons.assignment;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
