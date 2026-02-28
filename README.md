# Stride iOS

Native iOS application for smart errand management and personal place saving, powered by the Woosmap Geofencing SDK for automatic visit detection and geofence alerts. Built with Swift, SwiftUI, and modern iOS development practices.

## Overview

Stride iOS is a native iOS app providing intelligent errand and place management capabilities. The app follows the MVVM architecture pattern with manual constructor-based dependency injection. It integrates the Woosmap Geofencing SDK to passively detect when you visit a saved place and to alert you when you're nearby with pending errands.

## Tech Stack

- **Language:** Swift 6
- **UI Framework:** SwiftUI
- **Minimum iOS:** 16.0 or later
- **Dependency Injection:** Manual constructor-based DI
- **HTTP Client:** URLSession (native)
- **Secure Storage:** iOS Keychain (native)
- **Location SDK:** WoosmapGeofencing (SPM) — visit detection + custom geofencing
- **Notifications:** UNUserNotificationCenter — local push alerts on geofence entry
- **Project Management:** XcodeGen

## Project Structure

```
StrideiOS/
├── Stride/
│   ├── App/
│   │   └── StrideApp.swift           # SwiftUI entry point, tracking lifecycle
│   ├── DI/
│   │   └── DependencyContainer.swift  # Manual DI factory
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Place.swift
│   │   ├── Errand.swift
│   │   ├── NearbyData.swift
│   │   └── PlaceCollection.swift
│   ├── Screens/
│   │   ├── LoginView.swift
│   │   ├── RegisterView.swift
│   │   ├── HomeView.swift
│   │   ├── PlacesView.swift
│   │   ├── ErrandsView.swift
│   │   ├── SmartRouteView.swift
│   │   ├── NearbyView.swift
│   │   ├── CollectionsView.swift
│   │   └── SettingsView.swift
│   ├── Services/
│   │   ├── AuthService.swift
│   │   ├── PlaceService.swift
│   │   ├── ErrandService.swift
│   │   ├── NearbyService.swift
│   │   ├── RouteService.swift
│   │   ├── CollectionService.swift
│   │   ├── NetworkService.swift
│   │   └── WoosmapManager.swift      # Visit detection + geofence alerts
│   ├── ViewModels/
│   │   ├── LoginViewModel.swift
│   │   ├── RegisterViewModel.swift
│   │   ├── HomeViewModel.swift
│   │   ├── PlacesViewModel.swift
│   │   ├── ErrandsViewModel.swift
│   │   ├── SmartRouteViewModel.swift
│   │   ├── NearbyViewModel.swift
│   │   ├── CollectionsViewModel.swift
│   │   └── SettingsViewModel.swift
│   ├── Utils/
│   │   ├── KeychainManager.swift
│   │   └── LocationManager.swift
│   └── Info.plist
├── Stride.xcodeproj/
├── project.yml                       # XcodeGen configuration (includes SPM packages)
└── .gitignore
```

## Setup Instructions

### Prerequisites

- macOS 12.0 or later
- Xcode 15.0 or later
- iOS 16.0+ device or simulator
- XcodeGen (`brew install xcodegen`)

### Installation

1. **Clone and navigate to project:**
   ```bash
   cd StrideiOS
   ```

2. **Regenerate the Xcode project (resolves SPM packages):**
   ```bash
   npx xcodegen generate
   # or: xcodegen generate
   ```

3. **Open project (SPM packages are resolved automatically):**
   ```bash
   open Stride.xcodeproj
   ```

4. **Select target and build:**
   - Select "Stride" scheme
   - Select iOS Simulator or device
   - Press Cmd+B to build or Cmd+R to run

> **Note:** Always run `xcodegen generate` after pulling changes that modify `project.yml` (e.g., new SPM packages).

## Build & Run

### Using Xcode
```bash
# Regenerate project and open
xcodegen generate && open Stride.xcodeproj

# Build from command line
xcodebuild -project Stride.xcodeproj -scheme Stride -configuration Debug

# Build for iPhone Simulator
xcodebuild -project Stride.xcodeproj -scheme Stride -sdk iphonesimulator
```

## Architecture

### MVVM Pattern
- **View:** SwiftUI components
- **ViewModel:** State management with `@Published` properties
- **Model:** User, Place, Errand, PlaceCollection, NearbyData

### Dependency Injection
Uses manual constructor-based dependency injection:
- `DependencyContainer`: Single factory class with `lazy var` singletons for all services and managers
- Explicit constructor injection with no runtime reflection
- All dependencies are type-safe and compile-time verified

### Woosmap Integration
`WoosmapManager` is a `@MainActor`-isolated singleton owned by `DependencyContainer`:
- **Visit detection:** `VisitServiceDelegate.processVisit` → Haversine match against saved places (100m threshold) → `PATCH /api/v1/places/:id/visit`
- **Geofencing:** Up to 7 custom circular geofences (100m radius) registered around saved places; `RegionsServiceDelegate.didEnterPOIRegion` → `POST /api/v1/nearby` → local `UNUserNotification`
- **Tracking lifecycle:** Started on login, stopped on logout via `.onChange(of: authService.isLoggedIn)` in `StrideApp`
- **API key:** `""` (visit detection and custom geofencing work without a Woosmap store key)
- **Swift 6 safety:** Delegate inner classes use `@unchecked Sendable` + `Task { @MainActor in ... }` pattern, identical to the existing `LocationDelegate`

### Data Flow
1. **Views** trigger actions on **ViewModels**
2. **ViewModels** call **Services** to fetch/process data
3. **Services** use **NetworkService** for API calls
4. **KeychainManager** handles secure token storage
5. **WoosmapManager** runs passively in the background for location events
6. **`@Published`** properties update Views automatically

## Dependencies

- **WoosmapGeofencing** (SPM) — `https://github.com/Woosmap/geofencing-ios-sdk-spm-release.git` from `4.0.0`
- All other functionality is built on native iOS frameworks (Security, Foundation, CoreLocation, UserNotifications, SwiftUI)

## Configuration

### Environment
Configure the backend API URL in `Services/NetworkService.swift`:
```swift
private let baseURL = "https://strideapi-1048111785674.us-central1.run.app" // Production
// or
private let baseURL = "http://localhost:5001" // Local development
```

### Permissions
The app requires the following permissions (configured in `Info.plist`):
- `NSLocationWhenInUseUsageDescription` — for smart routing and nearby search
- `NSLocationAlwaysAndWhenInUseUsageDescription` — for background geofence alerts and visit detection
- `UIBackgroundModes: [location]` — required for Woosmap SDK background tracking

## Features

- ✅ User Authentication (Login/Register)
- ✅ Secure Token Storage (Keychain)
- ✅ Place Management (CRUD, collections, tags)
- ✅ Errand Management (CRUD, priorities, deadlines)
- ✅ Smart Errand Routing
- ✅ Nearby Places & Errands
- ✅ Collections Management
- ✅ Settings (profile, password, account deletion)
- ✅ Visit Detection (Woosmap SDK — auto-records visits when you spend time at a saved place)
- ✅ Geofence Alerts (Woosmap SDK — local push notification with pending errands when near a saved place)

## Development Guidelines

### Code Style
- Use Swift naming conventions
- Follow SwiftUI best practices
- Keep Views focused and reusable
- Use `@StateObject` for ViewModel ownership
- Add `@MainActor` to any class that interacts with UI or `@MainActor`-isolated services

### Adding a New Service
1. Create `Stride/Services/MyService.swift` — `@MainActor final class`
2. Add `private lazy var myService = MyService(networkService: networkService)` in `DependencyContainer`
3. Expose as `func makeMyService() -> MyService { myService }`

### Testing
- Unit tests can be added to the Xcode test target
- Use mock services for testing ViewModels

## Troubleshooting

### Build Fails After Pulling
```bash
# Regenerate the Xcode project (picks up project.yml changes)
xcodegen generate
```

### SPM Package Not Resolving
```bash
# Reset package cache
rm -rf ~/Library/Developer/Xcode/DerivedData/*
# Then File → Packages → Reset Package Caches in Xcode
```

### Clean Build
```bash
xcodebuild -project Stride.xcodeproj -scheme Stride clean
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### Simulator Issues
```bash
xcrun simctl erase all
xcrun simctl launch booted com.preetanshumishra.stride
```

## Stride Ecosystem

This project is part of the Stride smart errand and place management ecosystem:

- **[StrideAPI](https://github.com/preetanshumishra/StrideAPI)** - Node.js/Express backend API with MongoDB
- **[StrideAndroid](https://github.com/preetanshumishra/StrideAndroid)** - Native Android app (Kotlin + Jetpack Compose)

## License

MIT

## Author

Preetanshu Mishra
