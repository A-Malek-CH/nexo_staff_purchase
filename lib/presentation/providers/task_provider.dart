import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  return TasksNotifier(ref.read(taskRepositoryProvider));
});

class TasksState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final String? selectedStatus;
  final String? selectedPriority;

  TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.selectedStatus,
    this.selectedPriority,
  });

  TasksState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    String? selectedStatus,
    String? selectedPriority,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedPriority: selectedPriority ?? this.selectedPriority,
    );
  }

  List<Task> get todayTasks {
    final now = DateTime.now();
    return tasks.where((task) {
      return task.deadline.year == now.year &&
          task.deadline.month == now.month &&
          task.deadline.day == now.day;
    }).toList();
  }

  List<Task> get urgentTasks {
    return tasks.where((task) => task.priority == 'urgent').toList();
  }

  List<Task> get overdueTasks {
    final now = DateTime.now();
    return tasks.where((task) => task.deadline.isBefore(now) && task.status != 'completed').toList();
  }
}

class TasksNotifier extends StateNotifier<TasksState> {
  final TaskRepository _taskRepository;

  TasksNotifier(this._taskRepository) : super(TasksState());

  Future<void> loadTasks({String? status, String? priority}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedStatus: status,
      selectedPriority: priority,
    );

    try {
      final tasks = await _taskRepository.getTasks(
        status: status,
        priority: priority,
      );
      state = state.copyWith(
        tasks: tasks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshTasks() async {
    await loadTasks(
      status: state.selectedStatus,
      priority: state.selectedPriority,
    );
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      final updatedTask = await _taskRepository.updateTaskStatus(taskId, status);
      
      // Update the task in the list
      final updatedTasks = state.tasks.map((task) {
        return task.id == taskId ? updatedTask : task;
      }).toList();
      
      state = state.copyWith(tasks: updatedTasks);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void clearFilters() {
    state = state.copyWith(
      selectedStatus: null,
      selectedPriority: null,
    );
    loadTasks();
  }
}
