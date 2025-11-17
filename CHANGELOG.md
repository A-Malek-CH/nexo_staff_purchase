# Changelog

All notable changes to the Nexo Staff Purchase App will be documented in this file.

## [1.0.0] - 2025-11-17

### Added - Initial Release

#### Core Infrastructure
- Clean Architecture implementation with separation of concerns
- Riverpod state management setup
- GoRouter navigation with auth guards
- Dio HTTP client with interceptors
- Secure token storage using flutter_secure_storage
- Custom app theme (orange/beige color scheme)
- Build configuration for code generation

#### Authentication
- JWT-based authentication system
- Login screen with email/password validation
- Secure token storage (access and refresh tokens)
- Automatic token refresh on 401 errors
- Token injection in all API requests
- Logout functionality with token cleanup
- Auth guards for protected routes
- Automatic redirect based on auth state

#### Dashboard
- Welcome message with user name
- Today's tasks count card
- Urgent tasks count card
- Overdue tasks count card
- Total tasks count card
- Quick action buttons (Tasks, Products, Suppliers, Profile)
- Today's task preview (first 3 tasks)
- Notification badge with unread count
- Pull-to-refresh functionality

#### Tasks Module
- Tasks list screen with all assigned tasks
- Task status filter (pending, in_progress, completed, cancelled)
- Task priority filter (urgent, high, medium, low)
- Clear filters option
- Task cards with:
  - Priority indicator
  - Status badge
  - Deadline with overdue highlighting
  - Task title
- Task details screen (placeholder)
- Task report screen (placeholder)
- Pull-to-refresh
- Error handling and retry

#### Notifications
- Notifications list screen
- Unread notification badge
- Mark individual notification as read
- Mark all notifications as read
- Notification cards with read/unread state
- Pull-to-refresh

#### Products Module (View-Only)
- Products list screen (placeholder)
- Product details screen (placeholder)
- Navigation integration

#### Suppliers Module (View-Only)
- Suppliers list screen (placeholder)
- Supplier details screen (placeholder)
- Navigation integration

#### Profile
- Profile screen with user information
- User avatar (initials)
- Display name, email, role, phone
- Member since date
- Logout button with confirmation dialog

#### Data Models
- User model with JSON serialization
- Task model with items relationship
- TaskItem model with product details
- TaskReport model with photos support
- Product model with category
- Supplier model with contact info
- Category model
- NotificationModel
- AuthRequest (Login, RefreshToken)
- AuthResponse with user data

#### Services Layer
- AuthService for authentication API calls
- TaskService for task operations
- TaskReportService for report submission
- ProductService for product data
- SupplierService for supplier data
- NotificationService for notifications
- Error handling in all services

#### Repository Layer
- AuthRepository with token management
- TaskRepository with filtering
- TaskReportRepository
- ProductRepository
- SupplierRepository
- NotificationRepository

#### State Management
- AuthProvider (AuthNotifier + AuthState)
  - Login/logout actions
  - User state management
  - Auth status checking
- TasksProvider (TasksNotifier + TasksState)
  - Tasks list management
  - Filtering by status/priority
  - Today's/urgent/overdue tasks computed
- NotificationsProvider (NotificationsNotifier + NotificationsState)
  - Notifications list
  - Unread count tracking
  - Mark as read functionality

#### UI Components
- AppBottomNav - Bottom navigation bar
- Custom theme with Material Design 3
- Consistent card styling
- Orange/beige color scheme
- Rounded corners and shadows
- Large touch targets for mobile

#### Utilities
- DateHelper - Date formatting and relative time
- Validators - Email, password, required field validation
- UIHelper - SnackBar, dialog helpers
- AppConstants - API endpoints and configuration

#### Documentation
- Comprehensive README with:
  - Features overview
  - Architecture explanation
  - Installation instructions
  - API endpoints documentation
  - Theme details
  - Security notes
- PROJECT_STRUCTURE.md with detailed file structure
- Inline code comments
- This CHANGELOG

### Technical Details
- Flutter SDK: 3.7.0+
- Dart SDK: 3.7.0+
- Dependencies: Riverpod, GoRouter, Dio, flutter_secure_storage, json_annotation, intl
- Architecture: Clean Architecture
- State Management: Riverpod
- Navigation: GoRouter
- HTTP Client: Dio with interceptors
- Security: JWT with automatic refresh

### Future Enhancements
- [ ] Complete task details screen implementation
- [ ] Complete task report form with photo upload
- [ ] Complete products list and details
- [ ] Complete suppliers list and details
- [ ] Add search functionality
- [ ] Implement offline caching
- [ ] Add push notifications
- [ ] Add unit tests
- [ ] Add widget tests
- [ ] Add integration tests
- [ ] Add error reporting (e.g., Sentry)
- [ ] Add analytics
- [ ] Implement multi-language support
- [ ] Add dark mode theme
