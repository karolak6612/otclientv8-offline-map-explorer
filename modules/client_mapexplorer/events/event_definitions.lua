-- Event definitions for MapExplorer module

if _G.ExplorerEvents then
  return _G.ExplorerEvents
end

_G.ExplorerEvents = {
  -- Map Events
  MAP_LOADED = "MapLoaded",           -- (mapPath, version)
  MAP_CLEARED = "MapCleared",         -- ()
  
  -- Player Events
  PLAYER_POSITION_CHANGE = "PlayerPositionChange", -- (pos)
  PLAYER_SPEED_CHANGE = "PlayerSpeedChange",       -- (speed)
  PLAYER_OUTFIT_CHANGE = "PlayerOutfitChange",     -- (outfit)
  NOCLIP_CHANGE = "NoClipChange",                  -- (enabled)
  
  -- Camera/Light Events
  LIGHT_CHANGE = "LightChange",       -- (intensity, color)
  ZOOM_CHANGE = "ZoomChange",         -- (level, speed)
  
  -- UI Events
  BROWSER_PATH_CHANGE = "BrowserPathChange",       -- (path)
  TOOLS_VISIBILITY_CHANGE = "ToolsVisibilityChange", -- (visible)
  
  -- Spawn Simulation Events
  SPAWN_SIMULATION_START = "SpawnSimulationStart", -- ()
  SPAWN_SIMULATION_STOP = "SpawnSimulationStop",   -- ()
  SPAWN_LIST_CHANGE = "SpawnListChange",           -- (monsters, points)
}

return _G.ExplorerEvents
