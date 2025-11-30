# OTClientV8 - Offline Map Explorer

A powerful, offline map viewing and debugging tool for OTClientV8. This module allows you to explore OTBM maps, simulate spawns, and test outfits without connecting to a server.

## Features

*   **Offline Map Loading**: Load `.otbm` maps directly from your data directory.
*   **Version Support**: Automatically detects and supports multiple client versions (e.g., 10.98).
*   **Navigation**:
    *   **WASD / Arrows**: Move camera/player.
    *   **PageUp / PageDown**: Change floors.
    *   **Ctrl + Scroll**: Zoom in/out.
    *   **Ctrl + Click**: Teleport to any visible tile.
    *   **Ctrl + Arrows**: Rotate player.
*   **Tools Panel**:
    *   **Light Control**: Adjust ambient light intensity and color.
    *   **Speed Control**: Adjust player movement speed.
    *   **NoClip**: Walk through walls and obstacles.
    *   **Outfit**: Change player outfit (supports all game assets).
*   **Spawn Simulator**:
    *   Load `*-spawn.xml` files to visualize monster spawns.
    *   Simulate creature movement.
    *   Color-coded list (Green = Mapped, Red = Unmapped).

## Architecture

This module follows a **Service-Oriented Architecture (SOA)** with strict separation of concerns:

### 1. Configuration (`config/`)
*   `explorer_config.lua`: Centralized configuration for all constants (paths, defaults, limits).

### 2. State Management (`state/`)
*   `explorer_state.lua`: Single source of truth for application state. Reactive and validated.

### 3. Event System (`events/`)
*   `event_bus.lua`: Pub/Sub system for decoupled communication.
*   `event_definitions.lua`: List of all available events.

### 4. Services (`services/`)
*   `map_loader_service.lua`: Handles map loading, version detection, and asset loading.
*   `player_service.lua`: Manages player entity, movement, teleportation, and modes (noclip).
*   `lighting_service.lua`: Controls ambient lighting and color filters.
*   `outfit_service.lua`: Handles outfit selection, validation, and application.
*   `spawn_service.lua`: Manages spawn simulation, XML parsing, and creature lifecycle.
*   `persistence_service.lua`: Saves and restores state (position, camera, settings) between sessions.

### 5. UI Layer (`ui/`)
*   **Controllers** (`ui/controllers/`): Handle UI logic and bridge User -> Service interactions.
*   **Views** (`ui/views/`): OTUI layout definitions.
*   **Widgets** (`ui/widgets/`): Reusable UI components (e.g., FileBrowser).

## Usage

1.  Start OTClientV8.
2.  Click **"Offline Map Explorer"** in the main menu.
3.  Select an `.otbm` file from the file browser.
4.  Use the **Tools Panel** (bottom right) to customize your experience.
5.  Open **Spawn Simulator** via the "Spawns" button to load and test spawn files.

## Development

### Adding a New Service
1.  Create `services/my_new_service.lua`.
2.  Register it in `init.lua`.
3.  Add it to `mapexplorer.otmod`.

### Adding a New Event
1.  Define the event key in `events/event_definitions.lua`.
2.  Emit it using `EventBus.emit(Events.MY_EVENT, data)`.
3.  Listen using `EventBus.on(Events.MY_EVENT, callback)`.

## Credits
Refactored by Antigravity (Google DeepMind) for improved maintainability and extensibility.
