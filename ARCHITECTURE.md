# Order Management Architecture

## Overview
This document describes the architecture of the Order Management feature in the Nexo Staff Purchase mobile app.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        Presentation Layer                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Orders     │  │    Order     │  │    Order     │      │
│  │   Screen     │─▶│   Details    │─▶│   Submit     │      │
│  │              │  │   Screen     │  │   Screen     │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                  │               │
│         └─────────────────┼──────────────────┘               │
│                           │                                  │
│                    ┌──────▼───────┐                          │
│                    │    Order     │                          │
│                    │   Provider   │                          │
│                    │ (StateNotifier)│                        │
│                    └──────┬───────┘                          │
│                           │                                  │
└───────────────────────────┼──────────────────────────────────┘
                            │
┌───────────────────────────┼──────────────────────────────────┐
│                    Domain Layer                               │
├───────────────────────────┼──────────────────────────────────┤
│                    ┌──────▼───────┐                          │
│                    │    Order     │                          │
│                    │  Repository  │                          │
│                    └──────┬───────┘                          │
│                           │                                  │
└───────────────────────────┼──────────────────────────────────┘
                            │
┌───────────────────────────┼──────────────────────────────────┐
│                      Data Layer                               │
├───────────────────────────┼──────────────────────────────────┤
│                    ┌──────▼───────┐                          │
│                    │    Order     │                          │
│                    │   Service    │                          │
│                    └──────┬───────┘                          │
│                           │                                  │
│                    ┌──────▼───────┐                          │
│                    │   DioClient  │                          │
│                    │   (HTTP)     │                          │
│                    └──────┬───────┘                          │
│                           │                                  │
└───────────────────────────┼──────────────────────────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │   Backend API │
                    │   /orders     │
                    └───────────────┘
```

## Layer Responsibilities

### 1. Presentation Layer (UI)
**Location**: `lib/presentation/screens/orders/`

#### OrdersScreen
- Display list of orders
- Status filtering
- Pull-to-refresh
- Navigation to details

#### OrderDetailsScreen
- Show complete order information
- Display supplier details
- Show product list with pricing
- Status history timeline
- Action buttons (Submit for Review)

#### OrderSubmitScreen
- Collect optional notes
- Submit order for review
- Handle success/error states

#### OrderProvider
**Location**: `lib/presentation/providers/order_provider.dart`
- State management using Riverpod
- Order list state
- Loading and error states
- Actions: loadOrders, refreshOrders, submitOrderForReview

### 2. Domain Layer (Business Logic)
**Location**: `lib/data/repositories/`

#### OrderRepository
- Business logic for orders
- Filtering methods:
  - `filterTodayOrders()`
  - `filterAssignedOrders()`
  - `filterOverdueOrders()`
- Wraps service calls

### 3. Data Layer (API Communication)
**Location**: `lib/data/services/` and `lib/data/models/`

#### OrderService
- Direct API communication
- Methods:
  - `getMyOrders(status, page, limit)` → List<Order>
  - `getOrderById(id)` → Order
  - `submitOrderForReview(orderId, notes)` → Order
- Error handling

#### Models
- `Order`: Main order entity
- `ProductOrder`: Order line items
- `StatusHistoryEntry`: Status change tracking

## Data Flow

### Loading Orders
```
User Action (Pull/Load)
    ↓
OrderProvider.loadOrders()
    ↓
OrderRepository.getMyOrders()
    ↓
OrderService.getMyOrders()
    ↓
DioClient (HTTP GET /orders)
    ↓
Backend API
    ↓
Parse JSON → Order models
    ↓
Update Provider State
    ↓
UI Re-renders
```

### Submitting Order for Review
```
User Taps "Submit for Review"
    ↓
Navigate to OrderSubmitScreen
    ↓
User Enters Notes (Optional)
    ↓
User Taps "Submit"
    ↓
OrderProvider.submitOrderForReview()
    ↓
OrderRepository.submitOrderForReview()
    ↓
OrderService.submitOrderForReview()
    ↓
DioClient (HTTP PUT /orders/:id)
    ↓
Backend Updates Status
    ↓
Return Updated Order
    ↓
Update Local State
    ↓
Navigate Back with Success Message
```

## State Management

### OrdersState
```dart
class OrdersState {
  final List<Order> orders;       // List of orders
  final bool isLoading;            // Loading indicator
  final String? error;             // Error message
  final String? selectedStatus;    // Current filter
  
  // Computed properties
  List<Order> get todayOrders;     // Orders due today
  List<Order> get assignedOrders;  // Orders staff can work on
  List<Order> get overdueOrders;   // Past expected date
}
```

## Navigation Flow

```
Login Screen
    ↓
Dashboard Screen
    ↓ (Tap "View Orders" or Bottom Nav "Orders")
    ↓
Orders Screen (List)
    ↓ (Tap Order Card)
    ↓
Order Details Screen
    ↓ (Tap "Submit for Review")
    ↓
Order Submit Screen
    ↓ (Submit)
    ↓
Back to Orders Screen
```

## Status Flow

```
not assigned (Grey)
    ↓ (Admin assigns)
    ↓
assigned (Blue) ← Staff works on this
    ↓ (Staff submits)
    ↓
pending_review (Orange) ← Awaiting admin
    ↓ (Admin verifies)
    ↓
verified (Green)
    ↓ (Payment processed)
    ↓
paid (Dark Green)

At any point before verified:
    ↓
canceled (Red)
```

## Dependency Injection

Using Riverpod providers:

```dart
// Service Layer
final orderServiceProvider = Provider<OrderService>(...)

// Repository Layer  
final orderRepositoryProvider = Provider<OrderRepository>(...)

// State Management
final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>(...)

// Individual Order Details
final orderDetailsProvider = FutureProvider.family<Order, String>(...)
```

## Error Handling

### Service Layer
- Catches DioException
- Extracts error message from response
- Returns user-friendly error message

### Provider Layer
- Catches all exceptions
- Updates error state
- Allows retry mechanism

### UI Layer
- Displays error messages
- Provides retry button
- Shows loading indicators

## Security Considerations

1. **Authentication**: All API calls include auth token via interceptor
2. **Authorization**: Orders filtered by staffId on client
3. **Input Validation**: Notes field validated before submission
4. **Error Messages**: Sanitized before display
5. **No Sensitive Data**: No passwords or tokens in logs

## Performance Optimizations

1. **Lazy Loading**: Orders loaded on demand
2. **Caching**: Provider maintains state across screen transitions
3. **Pagination Ready**: Service supports page parameter
4. **Efficient Rendering**: ListView.builder for long lists
5. **Pull-to-Refresh**: Manual refresh when needed

## Testing Strategy

### Unit Tests
- Test order model serialization
- Test repository filtering logic
- Test provider state transitions

### Integration Tests
- Test API service calls
- Test error handling
- Test state management flow

### Widget Tests
- Test screen rendering
- Test user interactions
- Test navigation flow

### End-to-End Tests
- Test complete order submission flow
- Test filtering and sorting
- Test error scenarios

## Future Enhancements

### Planned Features
1. Offline support with local database
2. Push notifications for status changes
3. Receipt photo upload
4. Search functionality
5. Advanced filtering (date range, supplier)
6. Order export functionality
7. Analytics dashboard

### Technical Debt
1. Add comprehensive unit tests
2. Implement error retry logic
3. Add request caching
4. Optimize image loading
5. Add accessibility features

## Conclusion

This architecture follows clean architecture principles with clear separation of concerns:
- ✅ Testable business logic
- ✅ Independent UI components
- ✅ Flexible data layer
- ✅ Maintainable code structure
- ✅ Scalable design
