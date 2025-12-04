class AppConstants {
  // App Info
  static const String appName = 'Nexo Staff App';
  static const String appVersion = '1.0.0';

  // API Configuration
  // Development backend URL for testing notifications
  static const String baseUrl = 'https://purchase-manag-git-development-haithem-fellahs-projects.vercel.app/api';
  static const String apiVersion = 'v1';
  
  // API Endpoints
  static const String authEndpoint = '$baseUrl/auth';
  static const String loginEndpoint = '/auth/login';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  static const String tasksEndpoint = '/tasks';
  static const String taskReportsEndpoint = '/task-reports';
  static const String productsEndpoint = '/products';
  static const String suppliersEndpoint = '/suppliers';
  static const String notificationsEndpoint = '/notifications';
  static const String profileEndpoint = '/profile';
  static const String ordersEndpoint = '/orders';
  static const String categoriesEndpoint = '/categories';
  static const String adminStaffsEndpoint = '/admin/staffs';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Network
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  
  // Pagination
  static const int pageSize = 20;
  
  // Task Status (Legacy - kept for backward compatibility)
  static const String taskStatusPending = 'pending';
  static const String taskStatusInProgress = 'in_progress';
  static const String taskStatusCompleted = 'completed';
  static const String taskStatusCancelled = 'cancelled';
  
  // Order Status
  static const String orderStatusNotAssigned = 'not assigned';
  static const String orderStatusAssigned = 'assigned';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusPaid = 'paid';
  static const String orderStatusCanceled = 'canceled';
  
  // Task Priority
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';
  static const String priorityUrgent = 'urgent';
  
  // Task Report Types
  static const String reportTypeLowStock = 'low_stock';
  static const String reportTypeUnavailable = 'unavailable';
  static const String reportTypeSupplierIssue = 'supplier_issue';
  static const String reportTypePriceChange = 'price_change';
  static const String reportTypeAlternative = 'alternative';
  static const String reportTypeOther = 'other';
}
