# UWH Portal Clubs - Backend Integration Guide

## Overview

This document outlines the API contract expectations for integrating the UWH Portal Clubs Flutter mockup with the ASP.NET Core backend. The mockup is designed to seamlessly connect to real APIs with minimal code changes.

## Architecture Overview

### Service Layer Design
- **Mock Services**: Current implementation for UI validation
- **API Services**: Production implementation (to be created)
- **Repository Pattern**: Abstraction layer between services and UI
- **Riverpod DI**: Environment-based service selection

### Environment Configuration
```dart
class EnvironmentConfig {
  static bool get useMockServices => kDebugMode; // Switch to false for production
  static String get apiBaseUrl => _getApiBaseUrl();
  
  static String _getApiBaseUrl() {
    if (kDebugMode) return 'http://localhost:5000';
    // Production/staging URLs to be configured
    return 'https://api.uwhportal.com';
  }
}
```

## Authentication Requirements

### JWT Token Management
- **Header Format**: `Authorization: Bearer {token}`
- **Token Refresh**: Automatic refresh before expiration
- **Logout Handling**: Clear tokens and redirect to login

### Expected User Context
```json
{
  "userId": "string",
  "email": "string", 
  "firstName": "string",
  "lastName": "string",
  "roles": ["string"],
  "clubMemberships": [
    {
      "clubId": "string",
      "role": "member|admin|coach",
      "joinedDate": "2024-01-01T00:00:00Z"
    }
  ]
}
```

## API Endpoints Specification

### 1. User Management

#### GET /api/users/me
**Purpose**: Get current user profile and club memberships
**Headers**: Authorization required
**Response**:
```json
{
  "id": "string",
  "email": "string",
  "firstName": "string", 
  "lastName": "string",
  "profileImageUrl": "string?",
  "clubMemberships": [
    {
      "clubId": "string",
      "clubName": "string",
      "role": "member|admin|coach",
      "joinedDate": "2024-01-01T00:00:00Z",
      "isActive": true
    }
  ]
}
```

#### PUT /api/users/me
**Purpose**: Update user profile
**Headers**: Authorization required
**Request Body**:
```json
{
  "firstName": "string",
  "lastName": "string",
  "profileImageUrl": "string?"
}
```

### 2. Club Management

#### GET /api/clubs
**Purpose**: Get all clubs user has access to
**Headers**: Authorization required
**Query Parameters**:
- `includeInactive`: boolean (default: false)
**Response**:
```json
[
  {
    "id": "string",
    "name": "string",
    "description": "string",
    "location": "string",
    "logoUrl": "string?",
    "isActive": true,
    "memberCount": 0,
    "establishedDate": "2024-01-01T00:00:00Z",
    "contactEmail": "string",
    "website": "string?",
    "userRole": "member|admin|coach|null"
  }
]
```

#### GET /api/clubs/{clubId}
**Purpose**: Get detailed club information
**Headers**: Authorization required
**Response**:
```json
{
  "id": "string",
  "name": "string", 
  "description": "string",
  "location": "string",
  "logoUrl": "string?",
  "isActive": true,
  "memberCount": 0,
  "establishedDate": "2024-01-01T00:00:00Z",
  "contactEmail": "string",
  "website": "string?",
  "userRole": "member|admin|coach|null",
  "members": [
    {
      "userId": "string",
      "firstName": "string",
      "lastName": "string", 
      "role": "member|admin|coach",
      "joinedDate": "2024-01-01T00:00:00Z"
    }
  ],
  "practicePatterns": [
    {
      "id": "string",
      "dayOfWeek": 0,
      "startTime": "19:00:00",
      "duration": "01:30:00",
      "location": "string",
      "level": "beginner|intermediate|advanced|open",
      "isActive": true
    }
  ]
}
```

#### POST /api/clubs/{clubId}/join
**Purpose**: Join a club
**Headers**: Authorization required
**Response**: 204 No Content

#### DELETE /api/clubs/{clubId}/leave  
**Purpose**: Leave a club
**Headers**: Authorization required
**Response**: 204 No Content

### 3. Practice Management

#### GET /api/clubs/{clubId}/practices
**Purpose**: Get practices for a club
**Headers**: Authorization required
**Query Parameters**:
- `startDate`: ISO date (default: today)
- `endDate`: ISO date (default: +30 days)
- `includeParticipation`: boolean (default: true)
**Response**:
```json
[
  {
    "id": "string",
    "clubId": "string",
    "title": "string",
    "description": "string",
    "dateTime": "2024-01-01T19:00:00Z",
    "duration": "01:30:00",
    "location": "string",
    "level": "beginner|intermediate|advanced|open",
    "maxParticipants": 20,
    "isActive": true,
    "createdDate": "2024-01-01T00:00:00Z",
    "userParticipation": {
      "status": "blank|yes|maybe|no|attended|missed",
      "rsvpDate": "2024-01-01T00:00:00Z?",
      "guestCount": 0
    },
    "participationSummary": {
      "yesCount": 0,
      "maybeCount": 0, 
      "noCount": 0,
      "blankCount": 0,
      "attendedCount": 0,
      "missedCount": 0
    }
  }
]
```

#### GET /api/practices/{practiceId}
**Purpose**: Get detailed practice information
**Headers**: Authorization required
**Response**: Same as practice object above with additional participants list

#### POST /api/practices/{practiceId}/rsvp
**Purpose**: Update RSVP status for a practice
**Headers**: Authorization required
**Request Body**:
```json
{
  "status": "blank|yes|maybe|no",
  "guestCount": 0
}
```
**Response**: 204 No Content

#### POST /api/practices/{practiceId}/bulk-rsvp
**Purpose**: Update RSVP status for multiple practices
**Headers**: Authorization required
**Request Body**:
```json
{
  "practiceIds": ["string"],
  "status": "yes|maybe|no",
  "guestCount": 0
}
```
**Response**: 204 No Content

## Error Response Format

All API endpoints should return consistent error responses:

```json
{
  "error": {
    "code": "string",
    "message": "string", 
    "details": "string?",
    "timestamp": "2024-01-01T00:00:00Z"
  }
}
```

### Common Error Codes
- `UNAUTHORIZED`: 401 - Invalid or expired token
- `FORBIDDEN`: 403 - Insufficient permissions
- `NOT_FOUND`: 404 - Resource not found
- `VALIDATION_ERROR`: 400 - Invalid request data
- `CONFLICT`: 409 - Resource conflict (e.g., already joined club)
- `RATE_LIMITED`: 429 - Too many requests
- `SERVER_ERROR`: 500 - Internal server error

## Data Validation Rules

### Practice RSVP
- Users can only RSVP to future practices
- RSVP window closes 2 hours before practice start
- Guest count must be 0-5
- Only club members can RSVP

### Club Membership
- Users can join multiple clubs
- Club admins can manage memberships
- Leaving a club removes all practice RSVPs

## Performance Considerations

### Caching Strategy
- Club list: Cache for 1 hour
- Practice list: Cache for 15 minutes  
- User profile: Cache for 30 minutes
- Invalidate cache on relevant mutations

### Pagination
- Large result sets should use cursor-based pagination
- Default page size: 50 items
- Maximum page size: 200 items

## Security Requirements

### Input Validation
- All user inputs must be sanitized
- Date ranges must be validated
- Guest counts must be within limits

### Authorization
- Users can only access clubs they're members of
- Admin actions require admin role
- Practice RSVP requires club membership

## Integration Checklist

- [ ] JWT authentication flow implemented
- [ ] All API endpoints documented and tested
- [ ] Error handling covers all scenarios
- [ ] Caching strategy implemented
- [ ] Rate limiting configured
- [ ] Input validation in place
- [ ] Authorization rules enforced
- [ ] Performance testing completed
- [ ] Security review passed
