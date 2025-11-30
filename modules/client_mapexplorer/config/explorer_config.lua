-- Configuration for MapExplorer module
-- All magic numbers and constants centralized here

if _G.ExplorerConfig then
  return _G.ExplorerConfig
end

_G.ExplorerConfig = {
  -- Rendering Settings
  DRAW_BUFFER_SIZE = 7,              -- Chunk buffer size (prevents black tiles on zoom)
  DEFAULT_VISIBLE_WIDTH = 15,        -- Default viewport width in tiles
  DEFAULT_VISIBLE_HEIGHT = 11,       -- Default viewport height in tiles
  DEFAULT_ZOOM_LEVEL = 11,           -- Default zoom level
  
  -- Map Settings
  DEFAULT_FLOOR = 7,                 -- Default spawn floor (ground level)
  MIN_FLOOR = 0,                     -- Minimum floor (sky)
  MAX_FLOOR = 15,                    -- Maximum floor (deep underground)
  
  -- Player Settings
  DEFAULT_PLAYER_NAME = "MapExplorer",
  DEFAULT_PLAYER_SPEED = 200,
  MIN_PLAYER_SPEED = 100,
  MAX_PLAYER_SPEED = 2000,
  SPEED_STEP = 50,
  
  -- Light Settings
  DEFAULT_LIGHT_INTENSITY = 255,     -- Full bright
  DEFAULT_LIGHT_COLOR = 215,         -- Default white-ish color
  MIN_LIGHT_INTENSITY = 0,           -- Complete darkness
  MAX_LIGHT_INTENSITY = 255,         -- Full brightness
  
  -- Zoom Settings
  DEFAULT_ZOOM_SPEED = 1,
  MIN_ZOOM_SPEED = 1,
  MAX_ZOOM_SPEED = 5,
  ZOOM_SPEED_STEP = 1,
  
  -- Outfit Settings
  MAX_OUTFIT_SCAN = 2000,            -- Max outfit IDs to scan
  CONSECUTIVE_INVALID_LIMIT = 10,    -- Stop scanning after N consecutive invalid outfits
  DEFAULT_OUTFIT_TYPE = 1,
  MAX_ADDONS = 3,                    -- 0, 1, 2, 3
  
  -- Spawn Simulation
  SIMULATION_TICK_MS = 1000,         -- Update interval in milliseconds
  CREATURE_MOVE_CHANCE = 0.33,       -- Probability creature moves (33%)
  
  -- Persistence
  AUTO_SAVE_INTERVAL_MS = 5000,      -- Auto-save every 5 seconds
  
  -- Paths
  DATA_DIR_TEMPLATE = "/data/things/%d",        -- %d = version number
  DEFAULT_MAP_BROWSER_PATH = "data/things/",
  SPAWN_CONFIG_FILE = "/settings/spawn_config.json",
  
  -- UI Layout
  FILE_BROWSER_ITEM_HEIGHT = 20,
  PALETTE_CELL_SIZE = 12,
  PALETTE_CELL_SPACING = 1,
  PALETTE_COLOR_COUNT = 216,         -- 6x6x6 color cube
  
  -- Settings Keys (g_settings)
  SETTINGS_PREFIX = "mapexplorer/",
  SETTINGS_KEYS = {
    LAST_MAP_PATH = "mapexplorer/lastMapPath",
    LAST_BROWSE_PATH = "mapexplorer/lastBrowsePath",
    CLIENT_VERSION = "mapexplorer/clientVersion",
    MAP_STATE_PREFIX = "map_state_",  -- + MD5(mapPath)
  }
}

return _G.ExplorerConfig
