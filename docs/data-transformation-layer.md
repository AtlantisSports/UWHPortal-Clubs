# Data Transformation Layer

## Overview

The data transformation layer provides a clean separation between your Flutter app's internal models and external API formats. This isolation makes backend integration much smoother and protects your app from API schema changes.

## Architecture

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Mappers    │    │   Backend API   │
│                 │    │              │    │                 │
│ Internal Models │◄──►│ Transform    │◄──►│ API Responses   │
│ (Club, Practice)│    │ Data Formats │    │ (JSON Schema)   │
└─────────────────┘    └──────────────┘    └─────────────────┘
```

## Key Benefits

### 1. **API Schema Independence**
- Your Flutter models stay stable even if API changes
- Backend team can modify field names without breaking your app
- Easy to handle different API versions

### 2. **Clean Integration Points**
- All API transformations happen in one place
- Easy to debug data mapping issues
- Clear separation of concerns

### 3. **Error Handling**
- Safe parsing with validation
- Graceful handling of malformed API responses
- Early detection of API contract violations

## Implementation

### Mappers Created

1. **`ClubMapper`** - Transforms club data
2. **`PracticeMapper`** - Transforms practice data  
3. **`PracticePatternMapper`** - Transforms practice pattern data

### Example Usage

#### From API Response to Internal Model
```dart
// API returns this JSON:
{
  "id": "club-123",
  "short_name": "Denver UWH",  // snake_case
  "contact_email": "info@denveruwh.com"
}

// Mapper transforms to internal model:
final club = ClubMapper.fromApiResponse(apiJson);
// Result: Club with shortName and contactEmail (camelCase)
```

#### From Internal Model to API Request
```dart
// Internal model:
final club = Club(
  name: "Denver UWH",
  shortName: "Denver",
  contactEmail: "info@denveruwh.com"
);

// Mapper transforms for API:
final apiData = ClubMapper.toApiRequest(club);
// Result: {"short_name": "Denver", "contact_email": "info@denveruwh.com"}
```

## Repository Integration

### Mock Repository (Current)
```dart
class MockClubRepository implements IClubRepository {
  @override
  Future<List<Club>> getAllClubs() async {
    // Uses existing mock data (already in correct format)
    return await MockDataService.getClubs();
  }
}
```

### API Repository (Future)
```dart
class ApiClubRepository implements IClubRepository {
  @override
  Future<List<Club>> getAllClubs() async {
    // Make API call
    final response = await apiClient.get('/clubs');
    
    // Transform using mapper
    return ClubMapper.fromApiResponseList(response.data);
  }
  
  @override
  Future<String?> createClub(Club club) async {
    // Transform to API format
    final requestData = ClubMapper.toApiRequest(club);
    
    // Make API call
    final response = await apiClient.post('/clubs', data: requestData);
    
    return response.data['id'];
  }
}
```

## Field Mapping Examples

### Common Transformations

| Internal (Flutter) | API (Backend) | Transformation |
|-------------------|---------------|----------------|
| `shortName` | `short_name` | camelCase ↔ snake_case |
| `contactEmail` | `contact_email` | camelCase ↔ snake_case |
| `isActive` | `is_active` | camelCase ↔ snake_case |
| `DateTime` objects | ISO8601 strings | Object ↔ String |
| `Duration` objects | Minutes (int) | Object ↔ Number |

### Custom Field Handling
```dart
// Handle API-specific field names
if (json['legacy_club_name'] != null) {
  transformed['name'] = json.remove('legacy_club_name');
}

// Handle different date formats
if (json['created_timestamp'] != null) {
  transformed['createdAt'] = DateTime.fromMillisecondsSinceEpoch(
    json['created_timestamp'] * 1000
  ).toIso8601String();
}
```

## Error Handling

### Safe Parsing
```dart
// Validate API response structure
static bool isValidApiResponse(Map<String, dynamic> json) {
  final requiredFields = ['id', 'name', 'location'];
  
  for (final field in requiredFields) {
    if (!json.containsKey(field) || json[field] == null) {
      return false;
    }
  }
  return true;
}

// Safe parsing with error handling
static Club? fromApiResponseSafe(Map<String, dynamic> json) {
  try {
    if (!isValidApiResponse(json)) {
      return null;
    }
    return fromApiResponse(json);
  } catch (e) {
    print('ClubMapper: Failed to parse API response: $e');
    return null;
  }
}
```

### Repository Error Handling
```dart
class ApiClubRepository {
  Future<List<Club>> getAllClubs() async {
    try {
      final response = await apiClient.get('/clubs');
      return ClubMapper.fromApiResponseList(response.data);
    } catch (e) {
      throw _handleApiError(e);
    }
  }
  
  Exception _handleApiError(dynamic error) {
    if (error.toString().contains('network')) {
      return Exception('Network error: Please check your connection');
    }
    // ... handle other error types
    return Exception('Unexpected error: ${error.toString()}');
  }
}
```

## Integration Timeline

### Phase 1: Current State ✅
- Mappers created and ready
- Mock repositories demonstrate usage patterns
- No breaking changes to existing code

### Phase 2: API Integration
1. Implement `ApiClubRepository`, `ApiPracticeRepository`, etc.
2. Update `RepositoryFactory` to use API repositories
3. Configure environment switching
4. Test with real backend

### Phase 3: Production Optimization
1. Add caching layer using mappers
2. Implement offline support
3. Add performance monitoring
4. Optimize data transformations

## Testing Strategy

### Unit Tests for Mappers
```dart
test('ClubMapper transforms API response correctly', () {
  final apiJson = {
    'id': 'club-123',
    'short_name': 'Denver UWH',
    'contact_email': 'info@denveruwh.com'
  };
  
  final club = ClubMapper.fromApiResponse(apiJson);
  
  expect(club.id, 'club-123');
  expect(club.shortName, 'Denver UWH');
  expect(club.contactEmail, 'info@denveruwh.com');
});
```

### Integration Tests
```dart
test('API repository uses mapper correctly', () async {
  // Mock API response
  when(mockApiClient.get('/clubs')).thenReturn(mockApiResponse);
  
  final repository = ApiClubRepository(mockApiClient);
  final clubs = await repository.getAllClubs();
  
  expect(clubs, isA<List<Club>>());
  expect(clubs.first.name, isNotEmpty);
});
```

## Benefits for Backend Integration

### For Frontend Team
- **Stable codebase** - Internal models don't change
- **Easy debugging** - All transformations in one place
- **Type safety** - Compile-time validation of data structures

### For Backend Team
- **API flexibility** - Can change field names without breaking frontend
- **Version compatibility** - Support multiple API versions easily
- **Clear contracts** - Mappers document expected data formats

### For Integration
- **Smooth transition** - Switch from mock to API with minimal changes
- **Incremental migration** - Can migrate endpoints one at a time
- **Rollback safety** - Easy to revert to mock data if needed

## Conclusion

The data transformation layer provides a robust foundation for backend integration. It isolates your Flutter app from API changes, provides clear integration points, and makes the transition from mock to real data seamless.

**Ready for backend integration**: ✅ The mappers are implemented and ready to use when your API is available.
