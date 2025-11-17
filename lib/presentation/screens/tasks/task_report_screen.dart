import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TaskReportScreen extends StatelessWidget {
  final String taskId;

  const TaskReportScreen({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task Report'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.report, size: 64, color: AppTheme.primaryOrange),
            const SizedBox(height: 16),
            Text('Task ID: $taskId', style: AppTheme.bodyLarge),
            const SizedBox(height: 8),
            const Text('Report form will be displayed here', style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
