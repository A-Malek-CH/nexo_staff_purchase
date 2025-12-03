# Refactoring Notes: Tasks to Orders

## Overview
This refactoring renamed the concept of "Tasks" to "Orders" throughout the mobile app to align with the backend API and better reflect the application's purpose.

## Changes Made

### 1. New Models Created
- **`order_model.dart`**: Main Order model with fields matching backend schema
  - `Order`: Contains order details, supplier info, items, status, and history
  - `ProductOrder`: Represents individual items in an order
  - `StatusHistoryEntry`: Tracks status changes over time
- **`order_model.g.dart`**: Generated JSON serialization code

### 2. Service Layer
- **`order_service.dart`**: API service for order operations
  - `getMyOrders()`: Fetches orders assigned to logged-in staff
  - `getOrderById(id)`: Retrieves single order details
  - `submitOrderForReview(orderId, notes)`: Changes order status to pending_review

### 3. Repository Layer
- **`order_repository.dart`**: Business logic for orders
  - Wraps order service calls
  - Provides filtering methods for today's orders, assigned orders, and overdue orders

### 4. State Management
- **`order_provider.dart`**: Riverpod provider for order state management
  - `OrdersState`: Holds order list, loading state, and filters
  - `OrdersNotifier`: Manages order-related actions and state updates

### 5. UI Screens
- **`orders_screen.dart`**: Displays list of orders with filtering
  - Shows order number, supplier, status, amount, and expected date
  - Filter by status (assigned, pending_review, verified, paid)
  
- **`order_details_screen.dart`**: Displays full order information
  - Order header with status badge
  - Supplier information
  - Product list with quantities and costs
  - Status history timeline
  - Action button to submit for review (if status is "assigned")
  
- **`order_submit_screen.dart`**: Allows staff to submit order for review
  - Optional notes field
  - Submits order and changes status to "pending_review"

### 6. Navigation Updates
- **`app_router.dart`**: Updated routes
  - `/tasks` → `/orders`
  - `/tasks/:id` → `/orders/:id`
  - `/tasks/:id/report` → `/orders/:id/submit`

### 7. UI Component Updates
- **`app_bottom_nav.dart`**: Changed navigation label from "Tasks" to "Orders"
- **`dashboard_screen.dart`**: Updated all task references to orders
  - Stats cards show order metrics
  - Quick actions link to orders
  - Today's orders preview

### 8. Constants
- **`app_constants.dart`**: Added order status constants
  - `orderStatusNotAssigned`: "not assigned"
  - `orderStatusAssigned`: "assigned"
  - `orderStatusPendingReview`: "pending_review"
  - `orderStatusVerified`: "verified"
  - `orderStatusPaid`: "paid"
  - `orderStatusCanceled`: "canceled"

## Order Status Flow
1. **not assigned** → Order created but not assigned to staff (grey)
2. **assigned** → Staff can work on this order (blue)
3. **pending_review** → Waiting for admin review (orange)
4. **verified** → Admin has verified the order (green)
5. **paid** → Order has been paid (dark green)
6. **canceled** → Order was canceled (red - allowed before verified)

## Backend Integration
- Base URL: `https://purchase-manag.vercel.app/api`
- Orders Endpoint: `/orders`
- The app filters orders to show only those assigned to the logged-in staff member

## Read-Only Views
The Products and Suppliers screens remain read-only for staff users (no add/edit/delete actions).

## Backward Compatibility
- Old task-related files remain in the codebase but are no longer used
- Task constants retained in `app_constants.dart` for potential future use
- No breaking changes to existing data structures used elsewhere

## Testing Credentials
- Email: `chmalek19@gmail.com`
- Password: `Password123`
