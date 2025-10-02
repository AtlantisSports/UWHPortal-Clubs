# UWH Portal - API Contracts Documentation

This document defines the API contracts required for backend integration based on the current repository interfaces and mock data behavior.

## Overview

The Flutter app uses a repository pattern with clean interfaces that define exactly what the backend API needs to provide. This document specifies the required endpoints, request/response formats, and data models.

## Base Configuration

- **Base URL**: Environment-specific (see EnvironmentConfig.apiBaseUrl)
  - Development: `https://dev-api.uwhportal.com`
  - Staging: `https://staging-api.uwhportal.com`
  - Production: `https://api.uwhportal.com`
- **API Version**: `/v1` (configurable via AppConstants.apiVersion)
- **Authentication**: Bearer token in Authorization header
- **Content-Type**: `application/json`
- **Error Format**: Standardized error responses with status codes

## Common Response Format

```json
{
  "success": boolean,
  "data": any,
  "error": {
    "code": string,
    "message": string,
    "details": any
  },
  "pagination": {
    "page": number,
    "limit": number,
    "total": number,
    "hasMore": boolean
  }
}
```

## 1. Club Management API

### 1.1 Get All Clubs
**Endpoint**: `GET /clubs`

**Query Parameters**:
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)
- `search` (optional): Search term for name/description/location
- `location` (optional): Filter by location
- `tags` (optional): Comma-separated list of tags

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": "string",
      "name": "string",
      "shortName": "string",
      "longName": "string", 
      "description": "string",
      "logoUrl": "string|null",
      "location": "string",
      "contactEmail": "string",
      "website": "string|null",
      "isActive": boolean,
      "tags": ["string"],
      "memberCount": number,
      "createdAt": "ISO8601",
      "updatedAt": "ISO8601",
      "upcomingPractices": [
        {
          "id": "string",
          "clubId": "string",
          "patternId": "string|null",
          "title": "string",
          "description": "string",
          "dateTime": "ISO8601",
          "location": "string",
          "address": "string",
          "duration": number,
          "maxParticipants": number,
          "participants": ["string"],
          "participationResponses": {
            "userId": "yes|no|maybe"
          },
          "isRecurring": boolean,
          "tags": ["string"],
          "createdAt": "ISO8601",
          "updatedAt": "ISO8601"
        }
      ]
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 50,
    "hasMore": true
  }
}
```

### 1.2 Get Club by ID
**Endpoint**: `GET /clubs/{clubId}`

**Response**: Single club object (same format as above)

### 1.3 Get Clubs by Location
**Endpoint**: `GET /clubs/location/{location}`

**Response**: Array of clubs in specified location

### 1.4 Search Clubs
**Endpoint**: `GET /clubs/search?q={query}`

**Response**: Array of clubs matching search criteria

### 1.5 Get User's Clubs
**Endpoint**: `GET /users/{userId}/clubs`

**Response**: Array of clubs user is a member of

### 1.6 Create Club
**Endpoint**: `POST /clubs`

**Request Body**:
```json
{
  "name": "string",
  "shortName": "string",
  "longName": "string",
  "description": "string",
  "logoUrl": "string|null",
  "location": "string", 
  "contactEmail": "string",
  "website": "string|null",
  "tags": ["string"]
}
```

### 1.7 Update Club
**Endpoint**: `PUT /clubs/{clubId}`

**Request Body**: Same as create club

### 1.8 Delete Club
**Endpoint**: `DELETE /clubs/{clubId}`

### 1.9 Join Club
**Endpoint**: `POST /clubs/{clubId}/members`

**Request Body**:
```json
{
  "userId": "string",
  "role": "member|admin|coach"
}
```

### 1.10 Leave Club
**Endpoint**: `DELETE /clubs/{clubId}/members/{userId}`

## 2. Practice Management API

### 2.1 Get Club Practices
**Endpoint**: `GET /clubs/{clubId}/practices`

**Query Parameters**:
- `startDate` (optional): Filter practices from this date
- `endDate` (optional): Filter practices until this date
- `includeRecurring` (optional): Include recurring practices

### 2.2 Get Practice by ID
**Endpoint**: `GET /practices/{practiceId}`

### 2.3 Create Practice
**Endpoint**: `POST /practices`

**Request Body**:
```json
{
  "clubId": "string",
  "patternId": "string|null",
  "title": "string",
  "description": "string",
  "dateTime": "ISO8601",
  "location": "string",
  "address": "string",
  "duration": number,
  "maxParticipants": number,
  "tags": ["string"]
}
```

### 2.4 Update Practice
**Endpoint**: `PUT /practices/{practiceId}`

### 2.5 Delete Practice
**Endpoint**: `DELETE /practices/{practiceId}`

### 2.6 Get Practice Patterns
**Endpoint**: `GET /clubs/{clubId}/practice-patterns`

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": "string",
      "clubId": "string", 
      "title": "string",
      "description": "string",
      "day": "monday|tuesday|wednesday|thursday|friday|saturday|sunday",
      "startTime": {
        "hour": number,
        "minute": number
      },
      "duration": number,
      "location": "string",
      "address": "string",
      "tag": "string|null",
      "recurrence": {
        "type": "weekly|biweekly|monthly|custom",
        "interval": number,
        "endDate": "ISO8601|null"
      },
      "patternStartDate": "ISO8601|null",
      "patternEndDate": "ISO8601|null"
    }
  ]
}
```

### 2.7 Create Practice Pattern
**Endpoint**: `POST /practice-patterns`

### 2.8 Update Practice Pattern
**Endpoint**: `PUT /practice-patterns/{patternId}`

### 2.9 Delete Practice Pattern
**Endpoint**: `DELETE /practice-patterns/{patternId}`

### 2.10 Generate Practices from Pattern
**Endpoint**: `POST /practice-patterns/{patternId}/generate`

**Request Body**:
```json
{
  "startDate": "ISO8601",
  "endDate": "ISO8601"
}
```

## 3. Participation Management API

### 3.1 Get User Participation
**Endpoint**: `GET /users/{userId}/participation`

**Query Parameters**:
- `clubId` (optional): Filter by club
- `startDate` (optional): From date
- `endDate` (optional): Until date

### 3.2 Update RSVP Status
**Endpoint**: `PUT /practices/{practiceId}/rsvp`

**Request Body**:
```json
{
  "userId": "string",
  "status": "yes|no|maybe",
  "guests": [
    {
      "name": "string",
      "waiverSigned": boolean,
      "emergencyContact": "string|null"
    }
  ]
}
```

### 3.3 Bulk RSVP Update
**Endpoint**: `POST /practices/bulk-rsvp`

**Request Body**:
```json
{
  "userId": "string",
  "practiceIds": ["string"],
  "status": "yes|no|maybe",
  "timeframe": "thisWeek|nextWeek|thisMonth|nextMonth|custom",
  "startDate": "ISO8601|null",
  "endDate": "ISO8601|null"
}
```

### 3.4 Get Practice Participants
**Endpoint**: `GET /practices/{practiceId}/participants`

### 3.5 Get Participation Statistics
**Endpoint**: `GET /clubs/{clubId}/participation/stats`

**Query Parameters**:
- `period`: "week|month|quarter|year"
- `startDate` (optional)
- `endDate` (optional)

## 4. Error Handling

### Standard Error Codes
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (authentication required)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found (resource doesn't exist)
- `409` - Conflict (duplicate resource)
- `422` - Unprocessable Entity (business logic errors)
- `500` - Internal Server Error

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "email",
      "reason": "Invalid email format"
    }
  }
}
```

## 5. Authentication & Authorization

### Authentication
- **Method**: JWT Bearer tokens
- **Header**: `Authorization: Bearer <token>`
- **Token Refresh**: `POST /auth/refresh`

### Authorization Levels
- **Public**: View club information, practice schedules
- **Member**: RSVP to practices, view member areas
- **Admin**: Manage club settings, practices, members
- **Super Admin**: System-wide administration

## 6. Data Validation Rules

### Club Validation
- `name`: Required, 2-100 characters
- `location`: Required, 2-200 characters  
- `contactEmail`: Required, valid email format
- `website`: Optional, valid URL format

### Practice Validation
- `title`: Required, 2-200 characters
- `dateTime`: Required, future date/time
- `duration`: Required, 15 minutes to 8 hours
- `maxParticipants`: Optional, 1-200

### RSVP Validation
- `status`: Required, one of: yes|no|maybe
- `guests`: Optional array, max 5 guests per user
- `guest.name`: Required if guest provided, 2-100 characters
- `guest.waiverSigned`: Required boolean

## 7. Rate Limiting

- **General API**: 1000 requests per hour per user
- **Bulk Operations**: 100 requests per hour per user
- **Search**: 500 requests per hour per user

## 8. Caching Strategy

### Client-Side Caching
- **Club Data**: Cache for 5 minutes
- **Practice Data**: Cache for 2 minutes  
- **User Participation**: Cache for 1 minute

### Server-Side Caching
- **Club Lists**: Cache for 10 minutes
- **Practice Patterns**: Cache for 1 hour
- **User Sessions**: Cache for 24 hours

## 9. Webhook Events (Optional)

For real-time updates, the API can send webhooks for:
- `practice.created`
- `practice.updated` 
- `practice.cancelled`
- `rsvp.updated`
- `club.member.joined`
- `club.member.left`

**Webhook Format**:
```json
{
  "event": "practice.updated",
  "timestamp": "ISO8601",
  "data": {
    "practiceId": "string",
    "clubId": "string",
    "changes": ["dateTime", "location"]
  }
}
```

## 10. Migration Strategy

### Phase 1: Core APIs
1. Club management (read-only)
2. Practice viewing
3. Basic RSVP functionality

### Phase 2: Full Features  
1. Club creation/editing
2. Practice management
3. Bulk RSVP operations
4. Advanced filtering

### Phase 3: Advanced Features
1. Practice patterns
2. Recurring practices
3. Statistics and reporting
4. Webhook notifications

This API contract ensures seamless integration between the Flutter frontend and backend services while maintaining the existing user experience and functionality.
