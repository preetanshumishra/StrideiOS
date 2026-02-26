# Stride iOS

Native iOS application for smart errand management and personal place saving. Built with Swift, SwiftUI, and modern iOS development practices.

## Overview

Stride iOS is a native iOS app providing intelligent errand and place management capabilities. The app follows the MVVM architecture pattern with manual constructor-based dependency injection.

## Tech Stack

- **Language:** Swift 6
- **UI Framework:** SwiftUI
- **Minimum iOS:** 16.0 or later
- **Dependency Injection:** Manual constructor-based DI
- **HTTP Client:** URLSession (native)
- **Secure Storage:** iOS Keychain (native)
- **Project Management:** xcodegen

## Project Structure

```
StrideiOS/
├── Stride/
│   ├── App/
│   │   └── StrideApp.swift           # SwiftUI entry point
│   ├── DI/
│   │   └── DependencyContainer.swift  # Manual DI factory
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Place.swift
│   │   ├── Errand.swift
│   │   └── PlaceCollection.swift
│   ├── Screens/
│   │   ├── LoginView.swift
│   │   ├── RegisterView.swift
│   │   ├── HomeView.swift
│   │   ├── PlacesView.swift
│   │   └── ErrandsView.swift
│   ├── Services/
│   │   ├── AuthService.swift
│   │   ├── PlaceService.swift
│   │   ├── ErrandService.swift
│   │   └── NetworkService.swift
│   ├── ViewModels/
│   │   ├── LoginViewModel.swift
│   │   ├── RegisterViewModel.swift
│   │   ├── HomeViewModel.swift
│   │   ├── PlacesViewModel.swift
│   │   └── ErrandsViewModel.swift
│   ├── Utils/
│   │   └── KeychainManager.swift
│   └── Info.plist
├── Stride.xcodeproj/
├── project.yml                       # xcodegen configuration
└── .gitignore
```

## Setup Instructions

### Prerequisites

- macOS 12.0 or later
- Xcode 15.0 or later
- iOS 16.0+ device or simulator

### Installation

1. **Clone and navigate to project:**
   ```bash
   cd StrideiOS
   ```

2. **Open project (SPM packages managed automatically):**
   ```bash
   open Stride.xcodeproj
   ```

3. **Select target and build:**
   - Select "Stride" scheme
   - Select iOS Simulator or device
   - Press Cmd+B to build or Cmd+R to run

## Build & Run

### Using Xcode
```bash
# Open project
open Stride.xcodeproj

# Build
xcodebuild -project Stride.xcodeproj -scheme Stride -configuration Debug

# Build for iPhone Simulator
xcodebuild -project Stride.xcodeproj -scheme Stride -sdk iphonesimulator
```

### Using Command Line
```bash
# Build
cd StrideiOS
xcodebuild -project Stride.xcodeproj -scheme Stride -configuration Debug -sdk iphonesimulator
```

## Architecture

### MVVM Pattern
- **View:** SwiftUI components (LoginView, RegisterView, HomeView, PlacesView, ErrandsView)
- **ViewModel:** State management with @Published properties
- **Model:** User, Place, Errand, and PlaceCollection objects

### Dependency Injection
Uses manual constructor-based dependency injection:
- `DependencyContainer`: Simple factory class for creating services and ViewModels
- Explicit constructor injection with no runtime reflection
- All dependencies are type-safe and compile-time verified

### Data Flow
1. **Views** trigger actions on **ViewModels**
2. **ViewModels** call **Services** to fetch/process data
3. **Services** use **NetworkService** for API calls
4. **KeychainManager** handles secure token storage
5. **@Published** properties update Views automatically

## Dependencies

The project uses **zero external dependencies**. All functionality is built on native iOS frameworks:
- **Security Framework:** Native iOS Keychain for secure token storage
- **Foundation:** Core utilities and networking (URLSession)
- **SwiftUI:** Native UI framework

This minimizes maintenance burden and reduces attack surface.

## Configuration

### Environment
Configure the backend API URL in `Services/NetworkService.swift`:
```swift
private let baseURL = "https://strideapi-1048111785674.us-central1.run.app" // Production
// or
private let baseURL = "http://localhost:5001" // Local development
```

The app currently uses the production Cloud Run URL by default.

## Features

- ✅ User Authentication (Login/Register)
- ✅ Secure Token Storage (Keychain)
- ✅ API Integration (URLSession)
- ✅ SwiftUI-based UI
- ✅ MVVM Architecture
- ✅ Dependency Injection
- ✅ iOS 16.0+ Compatibility
- ✅ Place Management (view, delete)
- ✅ Errand Management (view, complete, delete)

## Development Guidelines

### Code Style
- Use Swift naming conventions
- Follow SwiftUI best practices
- Keep Views focused and reusable
- Use @StateObject for ViewModel ownership

### Testing
- Unit tests can be added to Xcode test target
- Use mock services for testing ViewModels

## Troubleshooting

### Build Fails
```bash
# Clean build
xcodebuild -project Stride.xcodeproj -scheme Stride clean

# Remove derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### Simulator Issues
```bash
# Reset simulator
xcrun simctl erase all

# Launch specific simulator
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
