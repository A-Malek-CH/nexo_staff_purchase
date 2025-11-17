# Nexo Staff Purchase App

A Flutter mobile application for store employees to manage purchase tasks assigned from the admin dashboard.

## Features

### Authentication
- JWT-based authentication with access and refresh tokens
- Secure token storage using flutter_secure_storage
- Automatic token refresh and request retry
- Auth guards and protected routes

### Dashboard
- Overview of today's tasks, urgent tasks, and overdue tasks
- Quick stats and metrics
- Quick action buttons for navigation
- Task preview

### Tasks Module
- View all assigned tasks with filtering (status, priority)
- Task details with supplier and product information
- Update task status and progress
- Upload receipts and product photos
- Complete tasks

### Task Reports
- Submit detailed reports for issues:
  - Low stock
  - Unavailable products
  - Supplier problems
  - Price changes
  - Alternative products
- Support for photos and detailed descriptions

### Notifications
- View all notifications
- Mark notifications as read
- Unread notification badge

### Products Module (View-Only)
- Browse products catalog
- View product details, categories, and images
- Search functionality

### Suppliers Module (View-Only)
- View supplier information
- Contact details and addresses
- Supplier notes

### Profile
- View user information
- Logout functionality

## Architecture

The app follows **Clean Architecture** principles with the following structure:

```
lib/
├── core/
│   ├── constants/      # App constants and configuration
│   ├── network/        # Dio client, interceptors, API response
│   ├── router/         # GoRouter configuration
│   ├── storage/        # Secure storage service
│   ├── theme/          # App theme and styling
│   └── utils/          # Helper functions and validators
├── data/
│   ├── models/         # Data models with JSON serialization
│   ├── repositories/   # Repository layer
│   └── services/       # API services
└── presentation/
    ├── providers/      # Riverpod state management
    ├── screens/        # UI screens
    └── widgets/        # Reusable widgets
```

## Tech Stack

- **Flutter 3.x**
- **Riverpod** - State management
- **GoRouter** - Navigation and routing
- **Dio** - HTTP client with interceptors
- **flutter_secure_storage** - Secure token storage
- **json_annotation/json_serializable** - JSON serialization
- **intl** - Date formatting

## Getting Started

### Prerequisites

- Flutter SDK 3.7.0 or higher
- Dart SDK 3.7.0 or higher

### Installation

1. Clone the repository
```bash
git clone https://github.com/A-Malek-CH/nexo_staff_purchase.git
cd nexo_staff_purchase
```

2. Install dependencies
```bash
flutter pub get
```

3. Generate code for JSON serialization (optional - already included)
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Configure API endpoint
Edit `lib/core/constants/app_constants.dart` and update the `baseUrl`:
```dart
static const String baseUrl = 'https://your-api-url.com';
```

5. Run the app
```bash
flutter run
```

## API Integration

The app is designed to work with a REST API backend. The following endpoints are expected:

### Authentication
- `POST /auth/login` - Login with email and password
- `POST /auth/refresh` - Refresh access token
- `POST /auth/logout` - Logout

### Tasks
- `GET /tasks` - Get all tasks (supports filtering)
- `GET /tasks/:id` - Get task details
- `PUT /tasks/:id` - Update task
- `POST /tasks/:taskId/items/:itemId/receipt` - Upload receipt
- `POST /tasks/:taskId/items/:itemId/photo` - Upload photo

### Task Reports
- `GET /task-reports` - Get all reports
- `POST /task-reports` - Create new report
- `POST /task-reports/upload` - Upload report photo

### Products
- `GET /products` - Get all products
- `GET /products/:id` - Get product details

### Suppliers
- `GET /suppliers` - Get all suppliers
- `GET /suppliers/:id` - Get supplier details

### Notifications
- `GET /notifications` - Get all notifications
- `PUT /notifications/:id/read` - Mark notification as read
- `PUT /notifications/read-all` - Mark all as read

### Profile
- `GET /profile` - Get user profile

## Theme

The app uses a custom theme matching the admin dashboard:

- **Primary Color**: Orange (#FF8C42)
- **Background**: Light beige/cream (#FFF8F0, #FFFBF5)
- **Cards**: White with rounded corners (16px radius)
- **Buttons**: Large with 12px border radius
- **Icons**: Minimal and intuitive

## Security

- JWT tokens are stored securely using `flutter_secure_storage`
- Automatic token refresh on 401 responses
- Auth guards prevent unauthorized access
- All API requests include JWT in Authorization header

## Testing

Run tests with:
```bash
flutter test
```

## Build

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is private and proprietary.

## Support

For support, contact the development team.
