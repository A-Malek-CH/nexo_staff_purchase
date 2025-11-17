# Developer Guide - Nexo Staff Purchase App

## Quick Start

### 1. Setup
```bash
# Clone the repository
git clone https://github.com/A-Malek-CH/nexo_staff_purchase.git
cd nexo_staff_purchase

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### 2. Configure Backend URL
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'https://your-api-url.com';
```

## How It Works

### Authentication Flow

1. **App Launch**:
   - `main.dart` wraps app in `ProviderScope`
   - `AuthNotifier` checks for stored tokens
   - GoRouter redirects based on auth state

2. **Login**:
   ```dart
   // User enters credentials
   await ref.read(authStateProvider.notifier).login(email, password);
   
   // AuthRepository calls AuthService
   // Tokens are saved to secure storage
   // User data is saved
   // State is updated, triggering navigation
   ```

3. **API Requests**:
   ```dart
   // Dio interceptor automatically adds JWT token
   headers: {'Authorization': 'Bearer $accessToken'}
   
   // If 401 error occurs, interceptor:
   // 1. Calls refresh token endpoint
   // 2. Saves new tokens
   // 3. Retries original request
   ```

4. **Logout**:
   ```dart
   await ref.read(authStateProvider.notifier).logout();
   // Clears all tokens
   // Resets state
   // Redirects to login
   ```

### State Management (Riverpod)

#### Reading State
```dart
// In a ConsumerWidget or ConsumerStatefulWidget
final authState = ref.watch(authStateProvider);
final tasksState = ref.watch(tasksProvider);

// Access data
print(authState.user?.name);
print(tasksState.tasks.length);
```

#### Updating State
```dart
// Call notifier methods
ref.read(tasksProvider.notifier).loadTasks();
ref.read(tasksProvider.notifier).updateTaskStatus(taskId, 'completed');
ref.read(notificationsProvider.notifier).markAsRead(notificationId);
```

#### Listen to Changes
```dart
ref.listen<TasksState>(tasksProvider, (previous, next) {
  if (next.error != null) {
    // Show error
  }
});
```

### Navigation (GoRouter)

#### Programmatic Navigation
```dart
// Navigate to a route
context.go('/dashboard');
context.push('/tasks');

// Navigate with parameters
context.push('/tasks/${task.id}');

// Go back
context.pop();
```

#### Route Definition
```dart
GoRoute(
  path: '/tasks/:id',
  name: 'task-details',
  builder: (context, state) {
    final taskId = state.pathParameters['id']!;
    return TaskDetailsScreen(taskId: taskId);
  },
),
```

### Making API Calls

#### 1. Define Service Method
```dart
// lib/data/services/task_service.dart
Future<List<Task>> getTasks({String? status}) async {
  final response = await _dio.get(
    AppConstants.tasksEndpoint,
    queryParameters: {'status': status},
  );
  return (response.data as List).map((e) => Task.fromJson(e)).toList();
}
```

#### 2. Use in Repository
```dart
// lib/data/repositories/task_repository.dart
Future<List<Task>> getTasks({String? status}) async {
  return await _taskService.getTasks(status: status);
}
```

#### 3. Call from Provider
```dart
// lib/presentation/providers/task_provider.dart
Future<void> loadTasks({String? status}) async {
  state = state.copyWith(isLoading: true);
  try {
    final tasks = await _taskRepository.getTasks(status: status);
    state = state.copyWith(tasks: tasks, isLoading: false);
  } catch (e) {
    state = state.copyWith(error: e.toString(), isLoading: false);
  }
}
```

#### 4. Use in UI
```dart
// In a screen
@override
void initState() {
  super.initState();
  Future.microtask(() {
    ref.read(tasksProvider.notifier).loadTasks();
  });
}

// In build method
final tasksState = ref.watch(tasksProvider);
if (tasksState.isLoading) return CircularProgressIndicator();
return ListView(children: tasksState.tasks.map(...).toList());
```

### Adding a New Feature

#### Example: Add "Mark Task as Favorite"

1. **Update Model** (`task_model.dart`):
```dart
class Task {
  final bool isFavorite;
  // ... other fields
  
  Task copyWith({bool? isFavorite}) {
    return Task(
      isFavorite: isFavorite ?? this.isFavorite,
      // ... copy other fields
    );
  }
}
```

2. **Add Service Method** (`task_service.dart`):
```dart
Future<Task> toggleFavorite(String taskId) async {
  final response = await _dio.put(
    '${AppConstants.tasksEndpoint}/$taskId/favorite',
  );
  return Task.fromJson(response.data);
}
```

3. **Add Repository Method** (`task_repository.dart`):
```dart
Future<Task> toggleFavorite(String taskId) async {
  return await _taskService.toggleFavorite(taskId);
}
```

4. **Add Provider Method** (`task_provider.dart`):
```dart
Future<void> toggleFavorite(String taskId) async {
  try {
    final updatedTask = await _taskRepository.toggleFavorite(taskId);
    final updatedTasks = state.tasks.map((task) {
      return task.id == taskId ? updatedTask : task;
    }).toList();
    state = state.copyWith(tasks: updatedTasks);
  } catch (e) {
    state = state.copyWith(error: e.toString());
  }
}
```

5. **Use in UI** (`tasks_screen.dart`):
```dart
IconButton(
  icon: Icon(task.isFavorite ? Icons.favorite : Icons.favorite_border),
  onPressed: () {
    ref.read(tasksProvider.notifier).toggleFavorite(task.id);
  },
)
```

### Common Patterns

#### Pull-to-Refresh
```dart
RefreshIndicator(
  onRefresh: () => ref.read(tasksProvider.notifier).refreshTasks(),
  child: ListView(...),
)
```

#### Error Handling
```dart
if (tasksState.error != null) {
  return Center(
    child: Column(
      children: [
        Text(tasksState.error!),
        ElevatedButton(
          onPressed: () => ref.read(tasksProvider.notifier).refreshTasks(),
          child: Text('Retry'),
        ),
      ],
    ),
  );
}
```

#### Loading State
```dart
tasksState.isLoading
  ? CircularProgressIndicator()
  : ListView(...)
```

#### Show SnackBar
```dart
UIHelper.showSnackBar(context, 'Task completed!');
UIHelper.showSnackBar(context, 'Error occurred', isError: true);
```

#### Confirmation Dialog
```dart
final confirmed = await UIHelper.showConfirmDialog(
  context,
  title: 'Delete Task',
  message: 'Are you sure?',
);
if (confirmed) {
  // Do something
}
```

### Debugging

#### Enable Dio Logging
Already enabled in `dio_client.dart`:
```dart
dio.interceptors.add(
  LogInterceptor(
    requestBody: true,
    responseBody: true,
  ),
);
```

#### Check Auth State
```dart
print('Is Authenticated: ${ref.read(authStateProvider).isAuthenticated}');
print('Current User: ${ref.read(authStateProvider).user?.name}');
```

#### Check Stored Tokens
```dart
final storage = ref.read(secureStorageServiceProvider);
final token = await storage.getAccessToken();
print('Access Token: $token');
```

## Testing

### Unit Tests
```dart
// test/unit/auth_repository_test.dart
void main() {
  group('AuthRepository', () {
    test('login should save tokens', () async {
      // Test implementation
    });
  });
}
```

### Widget Tests
```dart
// test/widget/login_screen_test.dart
void main() {
  testWidgets('LoginScreen shows email field', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp()));
    expect(find.byType(TextFormField), findsWidgets);
  });
}
```

## Building for Production

### Android
```bash
# Generate app bundle
flutter build appbundle --release

# Generate APK
flutter build apk --release --split-per-abi
```

### iOS
```bash
# Build for iOS
flutter build ios --release

# Create archive in Xcode
open ios/Runner.xcworkspace
# Product > Archive
```

## Best Practices

1. **Always use ref.read() for actions, ref.watch() for state**
2. **Handle errors in try-catch blocks**
3. **Show loading indicators during async operations**
4. **Use const constructors when possible**
5. **Keep widgets small and focused**
6. **Extract reusable widgets**
7. **Use meaningful variable names**
8. **Add comments for complex logic**
9. **Test on both Android and iOS**
10. **Check for memory leaks**

## Troubleshooting

### Build Errors
```bash
# Clean build
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Token Issues
```bash
# Clear app data (iOS)
flutter run --clear-app-data

# Or manually clear tokens
await ref.read(secureStorageServiceProvider).clearAll();
```

### Navigation Issues
- Check if route is defined in `app_router.dart`
- Verify auth guard logic
- Check if context is still mounted

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Dio Documentation](https://pub.dev/packages/dio)
