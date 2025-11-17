# API Integration Guide

This document describes the expected API endpoints and data formats for the Nexo Staff Purchase App.

## Base Configuration

Update the base URL in `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com/api/v1';
```

## Authentication Endpoints

### POST /auth/login
**Description**: Authenticate user with email and password

**Request Body**:
```json
{
  "email": "staff@example.com",
  "password": "password123"
}
```

**Response (200 OK)**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": {
    "id": "user-123",
    "email": "staff@example.com",
    "name": "John Doe",
    "phone": "+1234567890",
    "avatar": "https://...",
    "role": "staff",
    "is_active": true,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

**Error Response (401)**:
```json
{
  "message": "Invalid credentials"
}
```

---

### POST /auth/refresh
**Description**: Refresh access token using refresh token

**Request Body**:
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200 OK)**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": { /* same as login */ }
}
```

---

### POST /auth/logout
**Description**: Invalidate current tokens

**Headers**:
```
Authorization: Bearer {access_token}
```

**Response (200 OK)**:
```json
{
  "message": "Logged out successfully"
}
```

---

## Task Endpoints

### GET /tasks
**Description**: Get all tasks assigned to the authenticated user

**Headers**:
```
Authorization: Bearer {access_token}
```

**Query Parameters**:
- `status` (optional): pending, in_progress, completed, cancelled
- `priority` (optional): low, medium, high, urgent
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)

**Response (200 OK)**:
```json
{
  "data": [
    {
      "id": "task-123",
      "title": "Purchase office supplies",
      "description": "Buy items from supplier ABC",
      "status": "pending",
      "priority": "high",
      "deadline": "2024-12-25T10:00:00Z",
      "supplier_id": "supplier-456",
      "supplier_name": "ABC Supplies",
      "assigned_to": "user-123",
      "assigned_by": "admin-789",
      "items": [
        {
          "id": "item-001",
          "task_id": "task-123",
          "product_id": "prod-789",
          "product_name": "Printer Paper A4",
          "requested_quantity": 50,
          "actual_quantity": null,
          "requested_price": 5.99,
          "actual_price": null,
          "status": "pending",
          "is_available": true,
          "notes": null,
          "receipt_url": null,
          "photo_url": null,
          "purchased_at": null
        }
      ],
      "notes": "Contact supplier before visiting",
      "created_at": "2024-12-01T09:00:00Z",
      "updated_at": "2024-12-01T09:00:00Z",
      "completed_at": null
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_items": 87
  }
}
```

---

### GET /tasks/:id
**Description**: Get task details by ID

**Headers**:
```
Authorization: Bearer {access_token}
```

**Response (200 OK)**:
```json
{
  "id": "task-123",
  "title": "Purchase office supplies",
  /* ... same structure as task in list */
}
```

---

### PUT /tasks/:id
**Description**: Update task (status, items, etc.)

**Headers**:
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request Body** (example - update status):
```json
{
  "status": "in_progress"
}
```

**Response (200 OK)**:
```json
{
  /* updated task object */
}
```

---

### POST /tasks/:taskId/items/:itemId/receipt
**Description**: Upload receipt for a task item

**Headers**:
```
Authorization: Bearer {access_token}
Content-Type: multipart/form-data
```

**Form Data**:
- `file`: Receipt image file
- `task_id`: Task ID
- `item_id`: Item ID

**Response (200 OK)**:
```json
{
  "receipt_url": "https://storage.example.com/receipts/xyz.jpg",
  "message": "Receipt uploaded successfully"
}
```

---

### POST /tasks/:taskId/items/:itemId/photo
**Description**: Upload product photo for a task item

**Headers**:
```
Authorization: Bearer {access_token}
Content-Type: multipart/form-data
```

**Form Data**:
- `file`: Product photo file
- `task_id`: Task ID
- `item_id`: Item ID

**Response (200 OK)**:
```json
{
  "photo_url": "https://storage.example.com/photos/abc.jpg",
  "message": "Photo uploaded successfully"
}
```

---

## Task Report Endpoints

### GET /task-reports
**Description**: Get task reports

**Headers**:
```
Authorization: Bearer {access_token}
```

**Query Parameters**:
- `task_id` (optional): Filter by task ID
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response (200 OK)**:
```json
{
  "data": [
    {
      "id": "report-123",
      "task_id": "task-456",
      "report_type": "low_stock",
      "title": "Low stock on Item X",
      "description": "Supplier only had 10 units instead of 50",
      "photo_urls": ["https://storage.example.com/reports/img1.jpg"],
      "product_id": "prod-789",
      "supplier_id": "supplier-456",
      "price_change": null,
      "alternative_product": null,
      "status": "open",
      "reported_by": "user-123",
      "created_at": "2024-12-10T14:30:00Z",
      "resolved_at": null
    }
  ]
}
```

---

### POST /task-reports
**Description**: Create a new task report

**Headers**:
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "task_id": "task-456",
  "report_type": "price_change",
  "title": "Price increase on Product X",
  "description": "Supplier increased price from $5 to $7",
  "product_id": "prod-789",
  "supplier_id": "supplier-456",
  "price_change": 2.00,
  "photo_urls": ["https://storage.example.com/reports/price.jpg"]
}
```

**Report Types**:
- `low_stock`
- `unavailable`
- `supplier_issue`
- `price_change`
- `alternative`
- `other`

**Response (201 Created)**:
```json
{
  /* created report object */
}
```

---

### POST /task-reports/upload
**Description**: Upload photo for a report

**Headers**:
```
Authorization: Bearer {access_token}
Content-Type: multipart/form-data
```

**Form Data**:
- `file`: Photo file

**Response (200 OK)**:
```json
{
  "url": "https://storage.example.com/reports/photo123.jpg"
}
```

---

## Product Endpoints

### GET /products
**Description**: Get products list

**Headers**:
```
Authorization: Bearer {access_token}
```

**Query Parameters**:
- `category_id` (optional): Filter by category
- `search` (optional): Search by name/sku
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response (200 OK)**:
```json
{
  "data": [
    {
      "id": "prod-123",
      "name": "Printer Paper A4",
      "description": "High quality printer paper",
      "sku": "PP-A4-500",
      "category_id": "cat-001",
      "category_name": "Office Supplies",
      "price": 5.99,
      "min_quantity": 10,
      "unit": "ream",
      "image_url": "https://storage.example.com/products/paper.jpg",
      "images": ["https://..."],
      "is_active": true,
      "notes": "Order in multiples of 10",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-06-15T10:00:00Z"
    }
  ]
}
```

---

### GET /products/:id
**Description**: Get product details

**Headers**:
```
Authorization: Bearer {access_token}
```

**Response (200 OK)**:
```json
{
  /* product object */
}
```

---

## Supplier Endpoints

### GET /suppliers
**Description**: Get suppliers list

**Headers**:
```
Authorization: Bearer {access_token}
```

**Query Parameters**:
- `search` (optional): Search by name
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response (200 OK)**:
```json
{
  "data": [
    {
      "id": "supplier-123",
      "name": "ABC Office Supplies",
      "description": "Leading supplier of office products",
      "contact_person": "Jane Smith",
      "phone": "+1234567890",
      "email": "contact@abcsupplies.com",
      "address": "123 Business St",
      "city": "New York",
      "country": "USA",
      "notes": "Delivery available Mon-Fri",
      "is_active": true,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-06-15T10:00:00Z"
    }
  ]
}
```

---

### GET /suppliers/:id
**Description**: Get supplier details

**Headers**:
```
Authorization: Bearer {access_token}
```

**Response (200 OK)**:
```json
{
  /* supplier object */
}
```

---

## Notification Endpoints

### GET /notifications
**Description**: Get user notifications

**Headers**:
```
Authorization: Bearer {access_token}
```

**Query Parameters**:
- `is_read` (optional): true/false
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response (200 OK)**:
```json
{
  "data": [
    {
      "id": "notif-123",
      "title": "New Task Assigned",
      "message": "You have been assigned a new task: Purchase office supplies",
      "type": "task_assigned",
      "task_id": "task-456",
      "data": "{\"priority\":\"high\"}",
      "is_read": false,
      "user_id": "user-123",
      "created_at": "2024-12-10T09:00:00Z",
      "read_at": null
    }
  ]
}
```

**Notification Types**:
- `task_assigned`
- `task_updated`
- `task_deadline`
- `report_resolved`
- `system`

---

### PUT /notifications/:id/read
**Description**: Mark notification as read

**Headers**:
```
Authorization: Bearer {access_token}
```

**Response (200 OK)**:
```json
{
  "message": "Notification marked as read"
}
```

---

### PUT /notifications/read-all
**Description**: Mark all notifications as read

**Headers**:
```
Authorization: Bearer {access_token}
```

**Response (200 OK)**:
```json
{
  "message": "All notifications marked as read"
}
```

---

## Profile Endpoint

### GET /profile
**Description**: Get current user profile

**Headers**:
```
Authorization: Bearer {access_token}
```

**Response (200 OK)**:
```json
{
  "id": "user-123",
  "email": "staff@example.com",
  "name": "John Doe",
  "phone": "+1234567890",
  "avatar": "https://...",
  "role": "staff",
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

---

## Error Responses

All endpoints may return these error responses:

**401 Unauthorized**:
```json
{
  "message": "Unauthorized. Invalid or expired token."
}
```

**403 Forbidden**:
```json
{
  "message": "You don't have permission to access this resource."
}
```

**404 Not Found**:
```json
{
  "message": "Resource not found"
}
```

**422 Validation Error**:
```json
{
  "message": "Validation failed",
  "errors": {
    "email": ["The email field is required"],
    "password": ["The password must be at least 6 characters"]
  }
}
```

**500 Internal Server Error**:
```json
{
  "message": "Internal server error. Please try again later."
}
```

---

## Testing the Integration

### Using Postman

1. **Login**:
   - POST `{{baseUrl}}/auth/login`
   - Body: `{"email": "test@example.com", "password": "password"}`
   - Save `access_token` from response

2. **Get Tasks**:
   - GET `{{baseUrl}}/tasks`
   - Headers: `Authorization: Bearer {{access_token}}`

3. **Create Report**:
   - POST `{{baseUrl}}/task-reports`
   - Headers: `Authorization: Bearer {{access_token}}`
   - Body: Report JSON

### Using cURL

```bash
# Login
curl -X POST https://api.example.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'

# Get Tasks (replace TOKEN with actual token)
curl -X GET https://api.example.com/api/v1/tasks \
  -H "Authorization: Bearer TOKEN"
```

---

## Notes

1. All datetime fields should be in ISO 8601 format (UTC)
2. All endpoints (except login/refresh) require authentication
3. The app will automatically refresh tokens on 401 errors
4. File uploads use `multipart/form-data` encoding
5. JSON responses use snake_case for field names (converted to camelCase in app)
6. Pagination meta data is optional but recommended

---

## Backend Implementation Checklist

- [ ] Implement JWT token generation and validation
- [ ] Create refresh token rotation mechanism
- [ ] Set up file storage for receipts/photos
- [ ] Implement all CRUD endpoints
- [ ] Add proper error handling
- [ ] Set up CORS for mobile app
- [ ] Test token expiration and refresh flow
- [ ] Add rate limiting
- [ ] Set up database indexes for performance
- [ ] Add API documentation (Swagger/OpenAPI)
