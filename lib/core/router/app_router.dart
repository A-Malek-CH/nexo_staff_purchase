import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/order_model.dart';
import '../../data/models/supplier_model.dart';
import '../../data/models/product_model.dart' hide Category;
import '../../data/models/category_model.dart';
import '../../data/models/staff_member_model.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/orders/orders_screen.dart';
import '../../presentation/screens/orders/order_details_screen.dart';
import '../../presentation/screens/orders/submit_review_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/suppliers/suppliers_screen.dart';
import '../../presentation/screens/suppliers/supplier_details_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/tasks/tasks_screen.dart';
import '../../presentation/screens/tasks/task_details_screen.dart';
import '../../presentation/screens/transfers/transfers_screen.dart';
import '../../presentation/screens/transfers/transfer_details_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/staff/staff_list_screen.dart';
import '../../presentation/screens/admin/staff/staff_form_screen.dart';
import '../../presentation/screens/admin/suppliers/suppliers_list_screen.dart';
import '../../presentation/screens/admin/suppliers/supplier_form_screen.dart';
import '../../presentation/screens/admin/orders/orders_list_screen.dart';
import '../../presentation/screens/admin/orders/order_details_screen.dart' as admin_order;
import '../../presentation/screens/admin/orders/order_form_screen.dart';
import '../../presentation/screens/admin/orders/order_confirmation_screen.dart';
import '../../presentation/screens/admin/products/products_list_screen.dart';
import '../../presentation/screens/admin/products/product_form_screen.dart';
import '../../presentation/screens/admin/categories/categories_list_screen.dart';
import '../../presentation/screens/admin/categories/category_form_screen.dart';
import '../../presentation/screens/quick_access/quick_access_screen.dart';
import '../../presentation/screens/admin/analytics/analytics_screen.dart';


final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isLoginRoute = state.matchedLocation == '/login';
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final userRole = authState.user?.role ?? 'staff';

      // Wait for auth check to complete
      if (isLoading) return null;

      // Redirect to login if not authenticated and not already on login page
      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      // Role-based redirect from login
      if (isAuthenticated && isLoginRoute) {
        return userRole == 'admin' ? '/admin/dashboard' : '/dashboard';
      }

      // Prevent non-admins from accessing admin routes
      if (isAuthenticated && isAdminRoute && userRole != 'admin') {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/quick-access',
        name: 'quick-access',
        builder: (context, state) => const QuickAccessScreen(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/orders/details',
        name: 'order-details',
        builder: (context, state) {
          final order = state.extra as Order;
          return OrderDetailsScreen(order: order);
        },
      ),
      GoRoute(
        path: '/orders/submit',
        name: 'order-submit',
        builder: (context, state) {
          final order = state.extra as Order;
          return SubmitReviewScreen(order: order);
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/transfers',
        name: 'transfers',
        builder: (context, state) => const TransfersScreen(),
      ),
      GoRoute(
        path: '/transfers/:id',
        name: 'transfer-details',
        builder: (context, state) {
          final transferId = state.pathParameters['id']!;
          return TransferDetailsScreen(transferId: transferId);
        },
      ),
      GoRoute(
        path: '/suppliers',
        name: 'suppliers',
        builder: (context, state) => const SuppliersScreen(),
      ),
      GoRoute(
        path: '/suppliers/:id',
        name: 'supplier-details',
        builder: (context, state) {
          final supplierId = state.pathParameters['id']!;
          return SupplierDetailsScreen(supplierId: supplierId);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/tasks',
        name: 'tasks',
        builder: (context, state) => const TasksScreen(),
      ),
      GoRoute(
        path: '/tasks/:id',
        name: 'task-details',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          return TaskDetailsScreen(taskId: taskId);
        },
      ),

      // Admin routes
      GoRoute(
        path: '/admin/dashboard',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // Admin Staff
      GoRoute(
        path: '/admin/staff',
        name: 'admin-staff',
        builder: (context, state) => const StaffListScreen(),
      ),
      GoRoute(
        path: '/admin/staff/new',
        name: 'admin-staff-new',
        builder: (context, state) => const StaffFormScreen(),
      ),
      GoRoute(
        path: '/admin/staff/:id',
        name: 'admin-staff-edit',
        builder: (context, state) {
          final member = state.extra as StaffMember?;
          return StaffFormScreen(staffMember: member);
        },
      ),

      // Admin Suppliers
      GoRoute(
        path: '/admin/suppliers',
        name: 'admin-suppliers',
        builder: (context, state) => const SuppliersListScreen(),
      ),
      GoRoute(
        path: '/admin/suppliers/new',
        name: 'admin-suppliers-new',
        builder: (context, state) => const SupplierFormScreen(),
      ),
      GoRoute(
        path: '/admin/suppliers/:id',
        name: 'admin-suppliers-edit',
        builder: (context, state) {
          final supplier = state.extra as Supplier?;
          return SupplierFormScreen(supplier: supplier);
        },
      ),

      // Admin Orders
      GoRoute(
        path: '/admin/orders',
        name: 'admin-orders',
        builder: (context, state) => const OrdersListScreen(),
      ),
      GoRoute(
        path: '/admin/orders/new',
        name: 'admin-orders-new',
        builder: (context, state) => const OrderFormScreen(),
      ),
      GoRoute(
        path: '/admin/orders/:id',
        name: 'admin-orders-details',
        builder: (context, state) {
          final order = state.extra as Order;
          return admin_order.OrderDetailsScreen(order: order);
        },
      ),
      GoRoute(
        path: '/admin/orders/:id/confirm',
        name: 'admin-orders-confirm',
        builder: (context, state) {
          final order = state.extra as Order;
          return OrderConfirmationScreen(order: order);
        },
      ),

      // Admin Products
      GoRoute(
        path: '/admin/products',
        name: 'admin-products',
        builder: (context, state) => const ProductsListScreen(),
      ),
      GoRoute(
        path: '/admin/products/new',
        name: 'admin-products-new',
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/admin/products/:id',
        name: 'admin-products-edit',
        builder: (context, state) {
          final product = state.extra as Product?;
          return ProductFormScreen(product: product);
        },
      ),

      // Admin Categories
      GoRoute(
        path: '/admin/categories',
        name: 'admin-categories',
        builder: (context, state) => const CategoriesListScreen(),
      ),
      GoRoute(
        path: '/admin/categories/new',
        name: 'admin-categories-new',
        builder: (context, state) => const CategoryFormScreen(),
      ),
      GoRoute(
        path: '/admin/categories/:id',
        name: 'admin-categories-edit',
        builder: (context, state) {
          final category = state.extra as Category?;
          return CategoryFormScreen(category: category);
        },
      ),

      // Admin Analytics
      GoRoute(
        path: '/admin/analytics',
        name: 'admin-analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
  );
});
