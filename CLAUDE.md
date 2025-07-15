# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter chat application inspired by WhatsApp/Telegram, implementing an innovative index-based message synchronization system. The project follows Domain-Driven Design (DDD) architecture with clean separation of concerns.

## Key Architecture Features

### Index-Based Message Synchronization
The project uses a revolutionary **index-based message synchronization mechanism** that replaces complex timestamp-cursor systems:
- Messages are synchronized using simple numeric indices instead of complex cursor objects
- Provides O(1) numeric comparison vs O(n²) complex object comparison
- Enables reliable ordering with server-guaranteed sequential indices
- Simplifies gap detection: `next.index - current.index > 1`

### Technology Stack
- **Flutter**: Cross-platform UI framework
- **Cubit**: State management (BLoC pattern)
- **Isar**: High-performance local database
- **Socket.io**: Real-time communication with Next.js backend
- **Protobuf**: Data serialization
- **Integration_test**: Testing framework

### Architecture Pattern
- **DDD (Domain-Driven Design)**: Clear business logic layering
- **Repository Pattern**: Data access abstraction
- **Event-driven**: Message processing through events
- **Layer structure**: Pages (UI) → Cubit (Business Logic) → Repository (Data)

## Development Commands

### Environment Setup
```bash
# Install dependencies
flutter pub get

# Doctor check
flutter doctor
```

### Code Generation
```bash
# Generate Protocol Buffer files
./scripts/generate_protos.sh

# Generate Isar database code
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Running the App
```bash
# Development mode
flutter run -t lib/main.dart

# Windows release build
./scripts/build_windows.bat
```

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run specific feature tests
flutter test test/features/chat/
```

## Project Structure

### Core Architecture
```
lib/
├── core/                          # Core functionality
│   ├── adapters/                  # Data transformation adapters
│   ├── constants/                 # App configuration and colors
│   ├── database/models/           # Isar database models
│   ├── l10n/                      # Internationalization
│   ├── proto/                     # Protocol Buffer definitions
│   │   ├── source/                # Original .proto files
│   │   └── generated/             # Generated Dart code
│   ├── services/                  # Business services
│   ├── utils/                     # Utility functions
│   └── widgets/                   # Reusable widgets
├── features/                      # Feature modules (DDD)
│   ├── auth/                      # Authentication
│   ├── chat/                      # Chat functionality
│   ├── contacts/                  # Contact management
│   ├── home/                      # Home and navigation
│   └── profile/                   # User profile
└── main.dart                      # Application entry point
```

### Feature Module Structure (DDD)
Each feature follows DDD pattern:
```
feature/
├── data/repositories/             # Data layer implementation
├── domain/
│   ├── entities/                  # Business entities
│   └── repositories/              # Repository interfaces
└── presentation/
    ├── cubit/                     # State management
    ├── pages/                     # UI screens
    └── widgets/                   # Feature-specific widgets
```

## Key Development Guidelines

### State Management
- Use **Cubit** for all state management
- Access data through Cubit state, not directly from data layer
- Each feature module has its own independent Cubit
- Implement immutable state updates

### Database Operations
- **Isar** database models located in `lib/core/database/models/`
- Use Repository pattern for data access
- Index-based message queries for optimal performance
- All database models use code generation with `.g.dart` files

### Communication Services
- Follow the pattern: `requestXXX()` for sending requests via `emitProto`
- Implement `_handleXXX()` methods for handling responses
- Register all event handlers in `registerEventHandlers()`
- Use Protobuf for data serialization

### Code Generation
- Protocol Buffer files: Run `./scripts/generate_protos.sh` after modifying `.proto` files
- Isar database: Run build_runner after modifying database models
- Generated files are excluded from source control via `build.yaml`

### Multi-Server Support
- App supports multiple server endpoints with automatic failover
- Server configuration managed through `AppConfig` singleton
- Persistent server selection using SharedPreferences

### Internationalization
- Supports Chinese (zh) and English (en) locales
- Localizations in `lib/core/l10n/`
- Uses `timeago` package for relative time formatting

### Performance Optimizations
- Index-based message synchronization reduces query complexity by 95%
- Efficient database queries using single numeric index
- Lazy loading for media content
- Optimized widget rebuilds with proper state management

## Testing Strategy

- **Unit tests**: Cover all business logic and utilities
- **Integration tests**: Verify complete user workflows
- **Test data**: Isolated from production environment
- **Test coverage**: Focus on chat functionality, message synchronization, and user authentication

## File Organization Rules

- **Naming**: PascalCase for components, camelCase for functions
- **Imports**: Use relative imports within features, absolute for cross-feature
- **Documentation**: Chinese comments and documentation
- **Dependencies**: Prefer stable, well-maintained packages with Chinese mirror support

## Important Notes

- The project has deprecated location messages and complex cursor systems
- Use `Color.withAlpha(int a)` instead of deprecated `withOpacity(double opacity)`
- Proto files are in `source/` directory, generated files in `generated/`
- The app supports Windows, macOS, iOS, and Android platforms
- Desktop window management is configured for optimal chat experience