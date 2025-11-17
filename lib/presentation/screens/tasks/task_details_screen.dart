import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TaskDetailsScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailsScreen({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment, size: 64, color: AppTheme.primaryOrange),
            const SizedBox(height: 16),
            Text('Task ID: $taskId', style: AppTheme.bodyLarge),
            const SizedBox(height: 8),
            const Text('Task details will be displayed here', style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
