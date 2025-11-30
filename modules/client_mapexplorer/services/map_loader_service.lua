--- MapLoaderService
-- Handles map loading, version detection, and asset management.
-- @module MapLoaderService
MapLoaderService = {}

-- Dependencies (Global)
local Config = _G.ExplorerConfig
local ExplorerState = _G.ExplorerState
local EventBus = _G.ExplorerEventBus
local Events = _G.ExplorerEvents

function MapLoaderService.init()
  g_logger.info("MapLoaderService: init() called")
end

function MapLoaderService.terminate()
  -- Cleanup if needed
end

function MapLoaderService.setSelectedMap(path)
  ExplorerState.setMapPath(path)
  
  -- Auto-detect version from path
  local versionMatch = path:match("/things/(%d+)/")
  if versionMatch then
    local version = tonumber(versionMatch)
    ExplorerState.setMapVersion(version)
    g_settings.set(Config.SETTINGS_KEYS.CLIENT_VERSION, version) -- Update global setting for EnterGame
    
    -- Emit status update via UI (or EventBus if UI listens)
    if _G.MapExplorerUI then
        _G.MapExplorerUI.setStatus("Detected client version: " .. version)
    end
  end
end

function MapLoaderService.loadSelectedMap()
  local selectedMapPath = ExplorerState.getMapPath()
  if selectedMapPath == "" then
    if _G.MapExplorerUI then _G.MapExplorerUI.setStatus("No map selected") end
    return
  end
  
  if _G.MapExplorerUI then _G.MapExplorerUI.setStatus("Loading map...") end
  
  -- Schedule load to allow UI to update
  scheduleEvent(function()
    -- Load dependencies
    g_modules.ensureModuleLoaded('game_things')
    g_modules.ensureModuleLoaded('game_interface')
    g_modules.ensureModuleLoaded('game_outfit')
    
    if g_game.isOnline() then
      g_game.forceLogout()
      g_game.processGameEnd()
    end
    
    local selectedVersion = ExplorerState.getMapVersion()
    g_game.setClientVersion(selectedVersion)
    g_game.setProtocolVersion(g_game.getClientProtocolVersion(selectedVersion))
    
    -- Load Assets
    local dataDir = string.format(Config.DATA_DIR_TEMPLATE, selectedVersion)
    if not g_things.loadDat(dataDir .. '/Tibia') then
      if _G.MapExplorerUI then _G.MapExplorerUI.setStatus("Failed to load DAT file") end
      return
    end
    g_things.loadOtb(dataDir .. '/items.otb')
    if not g_things.isOtbLoaded() then
      if _G.MapExplorerUI then _G.MapExplorerUI.setStatus("Failed to load OTB file") end
      return
    end
    if not g_sprites.loadSpr(dataDir .. '/Tibia') then
      if _G.MapExplorerUI then _G.MapExplorerUI.setStatus("Failed to load SPR file") end
      return
    end
    
    -- Load map
    local mapPath = selectedMapPath
    if not g_resources.fileExists(mapPath) then
      if _G.MapExplorerUI then _G.MapExplorerUI.setStatus("Map file not found: " .. mapPath) end
      return
    end
    
    g_logger.info("Loading map: " .. mapPath)
    
    -- Clear existing map
    g_map.clean()
    
    -- Load OTBM
    local status, err = pcall(function()
      g_map.loadOtbm(mapPath)
    end)
    
    if not status then
      g_logger.error("Failed to load map: " .. tostring(err))
      if _G.MapExplorerUI then _G.MapExplorerUI.setStatus("Failed to load map: " .. tostring(err)) end
      return
    end
    
    if _G.MapExplorerUI then _G.MapExplorerUI.setStatus("Map loaded!") end
    ExplorerState.setMapLoaded(true)
    
    -- Emit MAP_LOADED event
    EventBus.emit(Events.MAP_LOADED, mapPath)
    
    -- Set initial position (center of map or saved pos)
    local player = g_game.getLocalPlayer()
    if not player then
      player = LocalPlayer.create()
      player:setOfflineMode(true)
      player:setName(Config.DEFAULT_PLAYER_NAME)
      g_game.setLocalPlayer(player)
    end
    
    -- Reset light to default before loading state
    ExplorerState.setLightIntensity(Config.DEFAULT_LIGHT_INTENSITY)
    
    -- Try to load state (PersistenceService will handle this later, but keeping logic here for now or delegating)
    -- For now, we'll assume PersistenceService isn't ready and do it inline or call a placeholder
    local stateLoaded = false
    if _G.PersistenceService then
        stateLoaded = _G.PersistenceService.loadMapState()
    elseif _G.MapExplorerGame and _G.MapExplorerGame.loadMapState then
        stateLoaded = _G.MapExplorerGame.loadMapState()
    end

    if not stateLoaded then
      -- Try to find a valid position if no state loaded
      local pos = nil -- MapExplorerGame.findSpawnPosition() -- TODO: Extract this too
      if not pos then
         -- Fallback to center if no valid tile found
         local mapSize = g_map.getSize()
         pos = {x = math.floor(mapSize.width / 2), y = math.floor(mapSize.height / 2), z = Config.DEFAULT_FLOOR}
      end
      
      player:setPosition(pos)
      g_map.addThing(player, pos, -1) -- Add player to map
      g_map.setCentralPosition(pos)
    else
       -- State loaded, just ensure player is added to map
       local pos = player:getPosition()
       g_map.addThing(player, pos, -1)
       g_map.setCentralPosition(pos)
    end
    
    -- Set ambient light (using loaded or default value)
    local light = ExplorerState.getLight()
    g_map.setLight(light)
    
    -- Start game interface
    g_game.processGameStart()
    
    -- Force minimap generation
    if g_minimap then
      g_minimap.clean()
      g_minimap.generateFromMap()
    end
  end, 100)
end

return MapLoaderService
