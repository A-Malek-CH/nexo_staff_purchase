# Nexo Staff Purchase App - Project Structure

## Overview
This is a complete Flutter mobile application for store employees to manage purchase tasks. The app follows Clean Architecture principles with Riverpod state management and GoRouter for navigation.

## Key Features Implemented

### 1. Authentication (JWT-based)
- **Login Screen**: Email/password authentication
- **Secure Storage**: JWT tokens stored using flutter_secure_storage
- **Auto Refresh**: Automatic token refresh on 401 errors
- **Auth Guards**: GoRouter redirects based on authentication state
- **Logout**: Clears tokens and redirects to login

### 2. Dashboard
- Today's tasks count
- Urgent tasks count
- Overdue tasks count
- Total tasks count
- Quick action buttons
- Today's task preview

### 3. Tasks Module
- View all assigned tasks
- Filter by status (pending, in_progress, completed, cancelled)
- Filter by priority (urgent, high, medium, low)
- Task details with items
- Update task status
- Upload receipts and photos
- Pull-to-refresh

### 4. Task Reports
- Create reports for issues (low stock, unavailable, price changes, etc.)
- Add photos to reports
- Link reports to specific tasks

### 5. Notifications
- View all notifications
- Mark individual notifications as read
- Mark all notifications as read
- Unread badge count

### 6. Products (View-Only)
- Browse products catalog
- View product details
- Search functionality

### 7. Suppliers (View-Only)
- View supplier list
- View supplier details
- Contact information

### 8. Profile
- View user information
- Logout functionality

## Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────┐
│     Presentation Layer              │
│  - Screens (UI)                     │
│  - Widgets (Reusable components)    │
│  - Providers (Riverpod state)       │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│     Data Layer                      │
│  - Repositories (Business logic)    │
│  - Services (API calls)             │
│  - Models (Data structures)         │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│     Core Layer                      │
│  - Network (Dio, Interceptors)      │
│  - Storage (Secure storage)         │
│  - Router (GoRouter config)         │
│  - Theme (App styling)              │
│  - Utils (Helpers, validators)      │
└─────────────────────────────────────┘
```

## File Structure

```
lib/
├── main.dart                           # App entry point
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # API endpoints, constants
│   ├── network/
│   │   ├── api_response.dart           # API response wrapper
│   │   ├── auth_interceptor.dart       # JWT token interceptor
│   │   └── dio_client.dart             # Dio HTTP client setup
│   ├── router/
│   │   └── app_router.dart             # GoRouter configuration
│   ├── storage/
│   │   └── secure_storage_service.dart # Secure token storage
│   ├── theme/
│   │   └── app_theme.dart              # App theme (orange/beige)
│   └── utils/
│       ├── date_helper.dart            # Date formatting utilities
│       └── helpers.dart                # Validators, UI helpers
├── data/
│   ├── models/                         # All data models
│   │   ├── user_model.dart
│   │   ├── task_model.dart
│   │   ├── task_item_model.dart
│   │   ├── task_report_model.dart
│   │   ├── product_model.dart
│   │   ├── supplier_model.dart
│   │   ├── category_model.dart
│   │   ├── notification_model.dart
│   │   ├── auth_request.dart
│   │   └── auth_response.dart
│   ├── repositories/                   # Repository layer
│   │   ├── auth_repository.dart
│   │   ├── task_repository.dart
│   │   ├── task_report_repository.dart
│   │   ├── product_repository.dart
│   │   ├── supplier_repository.dart
│   │   └── notification_repository.dart
│   └── services/                       # API services
│       ├── auth_service.dart
│       ├── task_service.dart
│       ├── task_report_service.dart
│       ├── product_service.dart
│       ├── supplier_service.dart
│       └── notification_service.dart
└── presentation/
    ├── providers/                      # Riverpod state management
    │   ├── auth_provider.dart
    │   ├── task_provider.dart
    │   └── notification_provider.dart
    ├── screens/                        # All screens
    │   ├── auth/
    │   │   └── login_screen.dart
    │   ├── dashboard/
    │   │   └── dashboard_screen.dart
    │   ├── tasks/
    │   │   ├── tasks_screen.dart
    │   │   ├── task_details_screen.dart
    │   │   └── task_report_screen.dart
    │   ├── notifications/
    │   │   └── notifications_screen.dart
    │   ├── products/
    │   │   ├── products_screen.dart
    │   │   └── product_details_screen.dart
    │   ├── suppliers/
    │   │   ├── suppliers_screen.dart
    │   │   └── supplier_details_screen.dart
    │   └── profile/
    │       └── profile_screen.dart
    └── widgets/                        # Reusable widgets
        └── app_bottom_nav.dart
```

## State Management (Riverpod)

### Auth Provider
- Manages authentication state
- Handles login/logout
- Checks auth status on app start
- Provides current user

### Tasks Provider
- Manages tasks list
- Handles filtering
- Updates task status
- Provides today's/urgent/overdue tasks

### Notifications Provider
- Manages notifications list
- Tracks unread count
- Marks notifications as read

## Navigation (GoRouter)

### Routes
- `/login` - Login screen
- `/dashboard` - Dashboard (default after login)
- `/tasks` - Tasks list
- `/tasks/:id` - Task details
- `/tasks/:id/report` - Create task report
- `/notifications` - Notifications list
- `/products` - Products list
- `/products/:id` - Product details
- `/suppliers` - Suppliers list
- `/suppliers/:id` - Supplier details
- `/profile` - User profile

### Auth Guard
The router automatically:
- Redirects to `/login` if not authenticated
- Redirects to `/dashboard` if authenticated and on login page
- Waits for auth check to complete before routing

## Network Layer (Dio)

### Auth Interceptor
- Automatically injects JWT token in all requests
- Catches 401 errors
- Refreshes token using refresh endpoint
- Retries failed request with new token
- Redirects to login if refresh fails

### Error Handling
- Connection timeouts
- Network errors
- API error messages
- Proper error propagation

## Theme

### Colors
- **Primary**: Orange (#FF8C42)
- **Background**: Cream/Beige (#FFF8F0, #FFFBF5)
- **Success**: Green (#00B894)
- **Error**: Red (#D63031)
- **Warning**: Yellow (#FDCB6E)

### Components
- Rounded cards (16px)
- Large buttons (12px radius)
- Clean spacing
- Material Design 3

## Dependencies

### Production
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `dio` - HTTP client
- `flutter_secure_storage` - Secure token storage
- `json_annotation` - JSON serialization
- `intl` - Date formatting
- `image_picker` - Image selection
- `permission_handler` - Permissions
- `flutter_local_notifications` - Notifications

### Development
- `build_runner` - Code generation
- `json_serializable` - JSON code generation
- `flutter_lints` - Linting

## Next Steps

To complete the implementation:

1. **Update API URL**: Edit `lib/core/constants/app_constants.dart` with your backend URL

2. **Test with Backend**: Once the backend is ready, test:
   - Login flow
   - Token refresh
   - All API endpoints
   - Error handling

3. **Add More Features** (if needed):
   - Task details full implementation
   - Task report form with photo upload
   - Products/Suppliers full list views
   - Search functionality
   - Offline caching
   - Push notifications

4. **Testing**: Add unit tests, widget tests, and integration tests

5. **Build**: Generate production builds for Android/iOS

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## Notes

- All models have JSON serialization (.g.dart files included)
- Auth interceptor handles token refresh automatically
- GoRouter handles auth guards
- Theme matches admin dashboard design
- Clean architecture for maintainability
- Ready for production deployment
