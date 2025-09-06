# UWH Portal - Clubs Flutter Mockup

This project follows the uwhportal monorepo architecture patterns for seamless integration.

## Project Structure

The Flutter project is organized following uwhportal conventions:

- `lib/features/` - Feature-specific code (clubs, events, auth)
- `lib/base/` - Reusable widgets and components  
- `lib/core/` - Core utilities, models, API client, constants
- `lib/core/api/` - API client compatible with uwhportal backend
- `lib/core/models/` - Data models matching backend structure
- `lib/core/constants/` - App constants, colors, text styles
- `lib/core/utils/` - Utility functions

## Architecture Guidelines

### Component Types
- **Pages**: Main screen components with navigation
- **Sections**: Reusable page sections  
- **Base Components**: Simple, atomic widgets (buttons, cards)
- **Complex Components**: Feature-specific composed widgets

### Backend Compatibility
- API client designed for ASP.NET Core compatibility
- Models match expected JSON structure from uwhportal API
- Authentication patterns prepared for JWT integration
- Follows REST conventions used by uwhportal backend

### Styling
- Colors and typography match uwhportal branding
- Ocean blue primary theme reflecting underwater hockey
- Consistent spacing and border radius constants
- Material 3 design system implementation

## Integration Strategy

### For uwhportal team integration:
1. Copy `lib/features/clubs/` to `mobile-app/lib/features/`
2. Copy `lib/base/widgets/` components to shared widget library
3. Adapt `lib/core/api/api_client.dart` to existing API patterns
4. Merge `lib/core/models/` with existing model definitions
5. Integration constants and styles with existing theme system

### API Endpoints Expected:
- `GET /clubs` - List clubs with filtering
- `GET /clubs/{id}` - Get club details  
- `POST /clubs` - Create club
- `PUT /clubs/{id}` - Update club
- `DELETE /clubs/{id}` - Delete club
- `POST /clubs/{id}/join` - Join club
- `POST /clubs/{id}/leave` - Leave club

## Development Notes

- Mock data used for development/testing
- TODO comments indicate integration points
- Error handling follows patterns expected by production app
- Responsive design considerations for mobile-first approach
- Accessibility features included where applicable

## Dependencies

- `http` - API communication
- `intl` - Date formatting and internationalization
- Standard Flutter Material components

This mockup serves as a foundation that can be easily merged into the main uwhportal mobile application.
