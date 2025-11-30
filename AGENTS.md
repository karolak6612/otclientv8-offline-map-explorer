# OTClientV8 - AI Agent Development Guide

## Project Overview

OTClientV8 is an open-source game client for Tibia (MMORPG) designed to work with Open Tibia servers. This is a sophisticated C++/Lua hybrid application with a modular architecture supporting Windows, Linux, and Android platforms.

**Key Characteristics:**
- **Primary Language**: C++17 with extensive Lua scripting
- **Architecture**: Modular framework with clear separation between core engine and game logic
- **Platforms**: Windows (Visual Studio), Linux (CMake), Android (NDK)
- **Build System**: CMake with vcpkg dependency management
- **Graphics**: OpenGL/DirectX with optional OpenGL ES for mobile

## Technology Stack

### Core Dependencies (vcpkg.json)
```
- Boost Libraries: iostreams, asio, beast, system, variant, lockfree, process
- Graphics: OpenGL, GLEW, ANGLE (Windows)
- Audio: OpenAL-soft, libogg, libvorbis  
- Networking: OpenSSL, WebSocket support
- Scripting: LuaJIT
- File Systems: PhysFS, zlib, libzip
```

### Project Structure
```
src/
├── framework/          # Core engine (graphics, sound, network, platform)
├── client/            # Game-specific logic (protocols, creatures, items)
└── lua/               # C++-Lua binding system

modules/
├── corelib/           # Core Lua libraries and utilities
├── gamelib/           # Game logic and protocol handling
├── game_*/            # Game feature modules (inventory, battle, minimap)
├── client_*/          # Client functionality (options, terminal)
└── game_bot/          # Botting functionality (vBot, cavebot, targetbot)

data/                  # Game assets, configurations, UI layouts
android/               # Android-specific code and build files
```

## Build Commands

### Windows (Visual Studio 2022)
```bash
# Using CMake presets
cmake --preset windows-release-static

# Manual build with vcpkg
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=[vcpkg-root]/scripts/buildsystems/vcpkg.cmake
cmake --build build --config Release
```

### Linux
```bash
# Standard CMake build
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build build

# With Ninja generator
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Release
ninja -C build
```

### Android
```bash
# Use Visual Studio with Android tools
# Open android/otclient_android.sln in Visual Studio
# Build for ARM64 architecture
```

## Testing

### Automated Testing
```bash
# Run test suite (Windows)
otclient_debug.exe --test

# Run with mobile UI testing
otclient_debug.exe --mobile

# CI testing via GitHub Actions
# Tests both DirectX and OpenGL backends
```

### Test Structure
- Test files in `tests/` directory (Lua scripts)
- Test data in `tests.7z` archive
- Screenshots captured for validation
- Exit code validation for success/failure

## Development Guidelines

### Code Style
- **C++ Standard**: C++17 across all platforms
- **Naming**: CamelCase for classes, snake_case for functions/variables
- **Memory Management**: RAII principles, smart pointers preferred
- **Error Handling**: Exceptions for C++, error codes for Lua bindings

### Module Development
Modules use `.otmod` definition files:
```yaml
Module
  name: example_module
  description: Example module
  author: Developer name
  reloadable: true
  sandboxed: true
  scripts: [ main.lua, utils.lua ]
  @onLoad: |
    -- Initialization code
  @onUnload: |
    -- Cleanup code
```

### Lua-C++ Integration
- C++ classes exposed via `@bindclass` annotation
- Template-based value conversion system
- Safe exception handling across language boundaries
- Module sandboxing for security

### Module Loading Order
1. **corelib** (priority 0-99) - Core utilities
2. **gamelib** (priority 100-499) - Game logic
3. **client** (priority 500-999) - Client interface
4. **game_interface** (priority 1000-9999) - Game UI

## Key Features to Consider

### Multi-Platform Support
- Windows: Win32 API, DirectX/OpenGL
- Linux: X11, OpenGL
- Android: Native Activity, OpenGL ES
- Cross-platform abstractions in `src/framework/platform/`

### Bot System
- Sophisticated botting framework in `modules/game_bot/`
- Cavebot for automated walking/hunting
- Targetbot for combat automation
- Configurable through Lua scripts

### Protocol Support
- Extensible protocol system for different Tibia versions
- Lua-based packet parsing
- Support for both official Tibia and OTServ protocols

### Mobile Features
- Android-specific UI adaptations
- Touch controls and virtual keyboard
- Screen orientation handling
- Asset packaging in `data.zip`

## Common Development Tasks

### Adding New Modules
1. Create module directory in `modules/`
2. Create `.otmod` definition file
3. Implement Lua scripts
4. Set appropriate loading priority
5. Test with hot-reload functionality

### Modifying UI
1. UI definitions in `.otui` files (XML-like format)
2. Lua widget extensions in `modules/corelib/ui/`
3. Style sheets in `data/styles/`
4. Test with different screen resolutions

### Adding Protocol Support
1. Extend protocol classes in `src/client/protocolgame*.cpp`
2. Update Lua bindings in `src/client/luavaluecasts.cpp`
3. Add game feature flags in `src/client/game.h`
4. Test with different server versions

## Security Considerations

### Module Sandboxing
- Modules can be sandboxed to prevent interference
- Controlled access to global Lua environment
- Dependency management prevents circular dependencies

### Encryption Support
- Support for encrypted game data
- OpenSSL integration for network security
- Secure updater mechanism

### Crash Reporting
- Built-in crash reporter service
- Configurable feedback system
- Error logging and diagnostics

## Performance Optimization

### Build Configurations
- Debug: Full symbols, no optimization
- Release: Optimized for performance
- RelWithDebInfo: Optimized with debug symbols

### Profiling Support
- Built-in performance monitoring
- Graphics profiling for render optimization
- Memory usage tracking

## Common Issues and Solutions

### Build Issues
- Ensure vcpkg dependencies are installed
- Check CMake version compatibility (3.5+)
- Verify graphics drivers for OpenGL/DirectX

### Runtime Issues
- Check module loading order for dependencies
- Verify Lua syntax in custom modules
- Test cross-platform compatibility

### Mobile-Specific
- Android permissions must be properly configured
- Asset packaging requires `create_android_assets.ps1`
- Screen size adaptations for different devices