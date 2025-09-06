# UWHPortal-Clubs

A modular Flutter mobile application designed for seamless integration with the underwater hockey portal ecosystem.

## Overview

This Flutter app provides a comprehensive clubs management interface for underwater hockey communities, featuring a complete navigation system, user role management, and phone frame mockup for development testing.

## Features

- **Complete Navigation System**: Bottom navigation with drawer integration
- **Phone Frame Mockup**: Realistic mobile device simulation for development
- **User Role Management**: Multiple user roles with permission-based features
- **Clubs Directory**: Browse and search underwater hockey clubs
- **Club Details**: View detailed club information with join/leave functionality
- **Hamburger Menu Navigation**: Consistent navigation across all screens
- **Back Button Handling**: Smart back navigation that closes drawers first
- **Responsive Design**: Mobile-first approach with clean, accessible UI
- **Backend Ready**: API client designed for integration

## Architecture

### Project Structure
```
lib/
├── features/           # Feature modules
│   ├── clubs/         # Club management screens & services
│   ├── events/        # Event management (placeholder)
│   └── auth/          # Authentication (placeholder)
├── base/              # Reusable components
│   └── widgets/       # Shared UI components
├── core/              # Core functionality
│   ├── api/          # API client & HTTP utilities
│   ├── models/       # Data models
│   ├── constants/    # App constants & theming
│   └── utils/        # Utility functions
└── main.dart         # App entry point
```

### Design Patterns

- **Feature Modules**: Self-contained feature folders following uwhportal conventions
- **Component Hierarchy**: Base components → Complex components → Feature screens
- **API Abstraction**: Centralized API client for backend communication
- **Theming**: Consistent design system with underwater hockey branding

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0+)
- Dart SDK (3.0.0+)
- Android Studio or VS Code with Flutter extension

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd clubs_mockup
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Integration with uwhportal

This mockup is designed for easy integration with the main uwhportal monorepo:

### Integration Steps

1. **Copy Feature Modules**:
   - Move `lib/features/clubs/` → `mobile-app/lib/features/clubs/`

2. **Merge Base Components**:
   - Integrate `lib/base/widgets/` with existing component library

3. **Adapt API Layer**:
   - Update `lib/core/api/api_client.dart` to use existing backend endpoints
   - Modify authentication headers to match current JWT implementation

4. **Update Models**:
   - Merge `lib/core/models/` with existing data models
   - Ensure JSON serialization matches API responses

5. **Theme Integration**:
   - Merge `lib/core/constants/app_constants.dart` with existing theme system

### Backend Compatibility

The API client expects these endpoints:
- `GET /clubs` - List clubs with optional filtering
- `GET /clubs/{id}` - Club details
- `POST /clubs` - Create club  
- `PUT /clubs/{id}` - Update club
- `POST /clubs/{id}/join` - Join club membership
- `POST /clubs/{id}/leave` - Leave club membership

## Development

### Adding Features
1. Create new feature folder under `lib/features/`
2. Add service class for API communication  
3. Create screen widgets following existing patterns
4. Update navigation in `main.dart`

### Styling Guidelines
- Use constants from `lib/core/constants/app_constants.dart`
- Follow Material 3 design principles
- Maintain consistency with uwhportal web interface
- Ensure accessibility compliance

### Testing
```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart
```

## Dependencies

- **http**: HTTP client for API communication
- **intl**: Internationalization and date formatting
- **flutter/material**: Material Design components

## Contributing

This mockup serves as a foundation for the uwhportal mobile application. When contributing:

1. Follow the established architecture patterns
2. Maintain compatibility with backend API structure  
3. Use consistent theming and component patterns
4. Document any new features or changes

## License

This project follows the same license as the main uwhportal repository.

## Contact

For questions about integration or contribution, please refer to the main underwater hockey portal development team.
