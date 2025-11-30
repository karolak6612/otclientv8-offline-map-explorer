MapExplorerGame = {}

local Config = _G.ExplorerConfig
local ExplorerState = _G.ExplorerState
local EventBus = _G.ExplorerEventBus
local Events = _G.ExplorerEvents

function MapExplorerGame.init()
  g_logger.info("MapExplorerGame: init() called")
  
  -- Load last used settings into State
  local lastPath = g_settings.getString(Config.SETTINGS_KEYS.LAST_MAP_PATH, '')
  ExplorerState.setMapPath(lastPath)
  
  local lastVersion = g_settings.getNumber(Config.SETTINGS_KEYS.CLIENT_VERSION, 1098)
  ExplorerState.setMapVersion(lastVersion)
  
  SpawnSimulator.init()
  
  -- Connect to game start
  connect(g_game, { onGameStart = MapExplorerGame.onGameStart,
                    onGameEnd = MapExplorerGame.onGameEnd })
  
  -- Bind floor change keys
  g_keyboard.bindKeyPress('PageUp', MapExplorerGame.floorUp)
  g_keyboard.bindKeyPress('PageDown', MapExplorerGame.floorDown)

  -- Bind Movement Keys (Fix for East/West stutter)
  g_keyboard.bindKeyPress('Up', function() g_game.walk(North) end)
  g_keyboard.bindKeyPress('Right', function() g_game.walk(East) end)
  g_keyboard.bindKeyPress('Down', function() g_game.walk(South) end)
  g_keyboard.bindKeyPress('Left', function() g_game.walk(West) end)

  -- Bind Rotation Keys (Ctrl + Arrows)
  g_keyboard.bindKeyDown('Ctrl+Up', function() MapExplorerGame.rotate(North) end)
  g_keyboard.bindKeyDown('Ctrl+Right', function() MapExplorerGame.rotate(East) end)
  g_keyboard.bindKeyDown('Ctrl+Down', function() MapExplorerGame.rotate(South) end)
  g_keyboard.bindKeyDown('Ctrl+Left', function() MapExplorerGame.rotate(West) end)

  -- Hook g_game.changeOutfit for offline mode
  if not g_game.originalChangeOutfit then
    g_game.originalChangeOutfit = g_game.changeOutfit
    g_game.changeOutfit = function(outfit)
      -- Always use offline logic in MapExplorer mode
      g_logger.info("MapExplorerGame: changeOutfit hook called")
      local player = g_game.getLocalPlayer()
      if player then
        -- Delegate to Outfit module for safe handling
        MapExplorerOutfit.applyOutfit(player, outfit)
      end
    end
  end
  -- Subscribe to events
  g_logger.info("MapExplorerGame: Subscribing to events...")
  g_logger.info("Events: " .. tostring(Events))
  if Events then
    g_logger.info("Events.LIGHT_CHANGE: " .. tostring(Events.LIGHT_CHANGE))
  end
  g_logger.info("Handler: " .. tostring(MapExplorerGame.onLightChangeEvent))

  if not Events then
    g_logger.error("MapExplorerGame: Events is nil! Aborting subscription.")
    return
  end

  EventBus.on(Events.LIGHT_CHANGE, MapExplorerGame.onLightChangeEvent)
  EventBus.on(Events.PLAYER_SPEED_CHANGE, MapExplorerGame.onSpeedChangeEvent)
  EventBus.on(Events.NO_CLIP_CHANGE, MapExplorerGame.onNoClipChangeEvent)
  EventBus.on(Events.ZOOM_CHANGE, MapExplorerGame.onZoomChangeEvent)
end

function MapExplorerGame.terminate()
  EventBus.off(Events.LIGHT_CHANGE, MapExplorerGame.onLightChangeEvent)
  EventBus.off(Events.PLAYER_SPEED_CHANGE, MapExplorerGame.onSpeedChangeEvent)
  EventBus.off(Events.NO_CLIP_CHANGE, MapExplorerGame.onNoClipChangeEvent)
  EventBus.off(Events.ZOOM_CHANGE, MapExplorerGame.onZoomChangeEvent)

  disconnect(g_game, { onGameStart = MapExplorerGame.onGameStart,
                       onGameEnd = MapExplorerGame.onGameEnd })

  
  g_keyboard.unbindKeyPress('PageUp', MapExplorerGame.floorUp)
  g_keyboard.unbindKeyPress('PageDown', MapExplorerGame.floorDown)

  g_keyboard.unbindKeyPress('Up', function() g_game.walk(North) end)
  g_keyboard.unbindKeyPress('Right', function() g_game.walk(East) end)
  g_keyboard.unbindKeyPress('Down', function() g_game.walk(South) end)
  g_keyboard.unbindKeyPress('Left', function() g_game.walk(West) end)

  g_keyboard.unbindKeyDown('Ctrl+Up', function() MapExplorerGame.rotate(North) end)
  g_keyboard.unbindKeyDown('Ctrl+Right', function() MapExplorerGame.rotate(East) end)
  g_keyboard.unbindKeyDown('Ctrl+Down', function() MapExplorerGame.rotate(South) end)
  g_keyboard.unbindKeyDown('Ctrl+Left', function() MapExplorerGame.rotate(West) end)
  
  -- Restore original changeOutfit if needed (optional, usually not needed on terminate)
  if g_game.originalChangeOutfit then
    g_game.changeOutfit = g_game.originalChangeOutfit
    g_game.originalChangeOutfit = nil
  end
end

function MapExplorerGame.rotate(dir)
  local player = g_game.getLocalPlayer()
  if player then
    player:setDirection(dir)
  end
end

function MapExplorerGame.onMinimapClick(widget, mousePos, mouseButton)
  if mouseButton == MouseLeftButton and g_keyboard.isCtrlPressed() then
    local pos = widget:getTilePosition(mousePos)
    if pos then
      MapExplorerGame.teleportTo(pos)
      return true
    end
  end
  return false
end

function MapExplorerGame.onGameStart()
  g_logger.info("MapExplorerGame: onGameStart")
  g_logger.info("MapExplorerGame: onGameStart")
  -- UI updates handled by MAP_LOADED event
  
  -- Hide EnterGame window
  if modules.client_entergame and modules.client_entergame.EnterGame then
    modules.client_entergame.EnterGame.hide()
  end
  
  -- Disable game_walking module to prevent conflict
  if modules.game_walking then
    g_modules.ensureModuleLoaded('game_walking') 
    if modules.game_walking.loaded then
      modules.game_walking.terminate()
    end
  end

  -- Hook Minimap Click
  if modules.game_minimap and modules.game_minimap.minimapWidget then
    modules.game_minimap.minimapWidget.onMouseRelease = MapExplorerGame.onMinimapClick
  end
  
  -- Start auto-save loop
  MapExplorerGame.autoSaveLoop()

  -- Initialize Extended Rendering (7x7 chunks to prevent black tiles on zoom)
  local mapPanel = modules.game_interface.getMapPanel()
  if mapPanel then
    mapPanel:setDrawBuffer({width=Config.DRAW_BUFFER_SIZE, height=Config.DRAW_BUFFER_SIZE})
    
    -- Hook Zoom (Ctrl + Scroll)
    local originalOnMouseWheel = mapPanel.onMouseWheel
    mapPanel.onMouseWheel = function(widget, mousePos, direction)
      if g_keyboard.isCtrlPressed() then
        local speed = ExplorerState.getZoomSpeed()
        for i = 1, speed do
            if direction == MouseWheelUp then
              widget:zoomIn()
            else
              widget:zoomOut()
            end
        end
        return true
      elseif originalOnMouseWheel then
        return originalOnMouseWheel(widget, mousePos, direction)
      end
      return false
    end
    
    -- Hook Map Click (Ctrl + Click Teleport)
    local originalOnMouseRelease = mapPanel.onMouseRelease
    mapPanel.onMouseRelease = function(widget, mousePos, mouseButton)
        if mouseButton == MouseLeftButton then
            if g_keyboard.isCtrlPressed() then
                local pos = widget:getPosition(mousePos)
                if pos then
                    MapExplorerGame.teleportTo(pos)
                    return true
                end
            else
                -- Disable default left-click (walk) to prevent crash
                return true
            end
        end
        
        if originalOnMouseRelease then
            return originalOnMouseRelease(widget, mousePos, mouseButton)
        end
        return false
    end

    -- Hook Mouse Press to prevent dragging/walking start
    local originalOnMousePress = mapPanel.onMousePress
    mapPanel.onMousePress = function(widget, mousePos, mouseButton)
        if mouseButton == MouseLeftButton then
             -- Always consume Left Click to prevent default drag/walk behavior
             return true
        end
        
        if originalOnMousePress then
            return originalOnMousePress(widget, mousePos, mouseButton)
        end
        return false
    end

    -- Hook Drag Move to be safe
    mapPanel.onDragMove = function(widget, mousePos, mouseMoved)
        return true -- Consume all drags
    end

    -- Hook Drag Enter/Leave to prevent cursor changes and crashes
    mapPanel.onDragEnter = function(widget, mousePos)
        return true -- Consume/Prevent default
    end

    mapPanel.onDragLeave = function(widget, droppedWidget, mousePos)
        return true -- Consume/Prevent default
    end

    -- Hook Mouse Move to prevent cursor changes
    mapPanel.onMouseMove = function(widget, mousePos, mouseMoved)
        return true -- Consume
    end
    
    -- Hook Hover to be safe
    mapPanel.onHoverChange = function(widget, hovered)
        return true
    end
  end
  
  -- Initialize Palette
  -- Palette initialized in UI module
end

function MapExplorerGame.resetView()
  local mapPanel = modules.game_interface.getMapPanel()
  if mapPanel then
    -- Reset Zoom (set visible dimension to default)
    mapPanel:setVisibleDimension({width = Config.DEFAULT_VISIBLE_WIDTH, height = Config.DEFAULT_VISIBLE_HEIGHT})
    mapPanel:setZoom(Config.DEFAULT_ZOOM_LEVEL) -- Sync internal zoom state
    
    -- Reset Zoom Speed
    ExplorerState.setZoomSpeed(Config.DEFAULT_ZOOM_SPEED)
    -- Reset Zoom Speed
    ExplorerState.setZoomSpeed(Config.DEFAULT_ZOOM_SPEED)
    
    -- Center on player
    local player = g_game.getLocalPlayer()
    if player then
        g_map.setCentralPosition(player:getPosition())
    end
  end
end

function MapExplorerGame.onGameEnd()
  g_logger.info("MapExplorerGame: onGameEnd")
  g_logger.info("MapExplorerGame: onGameEnd")
  MapExplorerGame.saveMapState()
  ExplorerState.setMapLoaded(false)
  
  -- Re-enable game_walking module
  if modules.game_walking then
     modules.game_walking.init()
  end
end

function MapExplorerGame.setSelectedMap(path)
  ExplorerState.setMapPath(path)
  
  -- Auto-detect version from path
  local versionMatch = path:match("/things/(%d+)/")
  if versionMatch then
    local version = tonumber(versionMatch)
    ExplorerState.setMapVersion(version)
    g_settings.set('client-version', version) -- Update global setting for EnterGame
    MapExplorerUI.setStatus("Detected client version: " .. version)
  end
end

-- Compatibility with EnterGame
MapExplorer = {}

function MapExplorer.show(version)
  if version then
      ExplorerState.setMapVersion(version)
  end
  MapExplorerUI.show()
end

function MapExplorer.hide()
  MapExplorerUI.hide()
end

function MapExplorerGame.loadSelectedMap()
  local selectedMapPath = ExplorerState.getMapPath()
  if selectedMapPath == "" then
    MapExplorerUI.setStatus("No map selected")
    return
  end
  
  MapExplorerUI.setStatus("Loading map...")
  
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
      MapExplorerUI.setStatus("Failed to load DAT file")
      return
    end
    g_things.loadOtb(dataDir .. '/items.otb')
    if not g_things.isOtbLoaded() then
      MapExplorerUI.setStatus("Failed to load OTB file")
      return
    end
    if not g_sprites.loadSpr(dataDir .. '/Tibia') then
      MapExplorerUI.setStatus("Failed to load SPR file")
      return
    end
    
    -- Load map
    local mapPath = selectedMapPath
    if not g_resources.fileExists(mapPath) then
      MapExplorerUI.setStatus("Map file not found: " .. mapPath)
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
      MapExplorerUI.setStatus("Failed to load map: " .. tostring(err))
      return
    end
    
    MapExplorerUI.setStatus("Map loaded!")
    MapExplorerUI.setStatus("Map loaded!")
    ExplorerState.setMapLoaded(true)
    
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
    
    -- Try to load state
    if not MapExplorerGame.loadMapState() then
      -- Try to find a valid position if no state loaded
      local pos = MapExplorerGame.findSpawnPosition()
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

function MapExplorerGame.findSpawnPosition()
  return nil
end

function MapExplorerGame.teleportTo(pos)
  local player = g_game.getLocalPlayer()
  if not player then return end
  
  -- Remove from old tile
  local oldTile = g_map.getTile(player:getPosition())
  if oldTile then oldTile:removeThing(player) end
  
  player:setPosition(pos)
  ExplorerState.setPlayerPosition(pos)
  
  local newTile = g_map.getTile(pos)
  if newTile then 
    newTile:addThing(player, -1)
  end
  g_map.setCentralPosition(pos)
end

function MapExplorerGame.floorUp()
  local player = g_game.getLocalPlayer()
  if not player then return end
  local pos = player:getPosition()
  pos.z = pos.z - 1
  if pos.z < Config.MIN_FLOOR then pos.z = Config.MIN_FLOOR end
  MapExplorerGame.teleportTo(pos)
end

function MapExplorerGame.floorDown()
  local player = g_game.getLocalPlayer()
  if not player then return end
  local pos = player:getPosition()
  pos.z = pos.z + 1
  if pos.z > Config.MAX_FLOOR then pos.z = Config.MAX_FLOOR end
  MapExplorerGame.teleportTo(pos)
end

function MapExplorerGame.onTeleport()
  local x = tonumber(MapExplorerUI.explorerPanel:getChildById('posX'):getText())
  local y = tonumber(MapExplorerUI.explorerPanel:getChildById('posY'):getText())
  local z = tonumber(MapExplorerUI.explorerPanel:getChildById('posZ'):getText())
  
  if x and y and z then
    local pos = {x=x, y=y, z=z}
    MapExplorerGame.teleportTo(pos)
  end
end

function MapExplorerGame.toggleNoClip(enabled)
  g_logger.info("MapExplorerGame: toggleNoClip " .. tostring(enabled))
  local player = g_game.getLocalPlayer()
  if player then
    player:setNoClipMode(enabled)
    ExplorerState.setNoClipEnabled(enabled)
  end
end

function MapExplorerGame.onSpeedChange(value)
  g_logger.info("Speed changed to: " .. tostring(value))
  local player = g_game.getLocalPlayer()
  if player then
    player:setSpeed(value)
    player:setBaseSpeed(value)
    ExplorerState.setPlayerSpeed(value)
  end
end

function MapExplorerGame.onZoomSpeedChange(value)
  g_logger.info("Zoom speed changed to: " .. tostring(value))
  ExplorerState.setZoomSpeed(value)
end

function MapExplorerGame.onColorChange(value)
  g_logger.info("Color changed to: " .. tostring(value))
  ExplorerState.setLightColor(value)
end

function MapExplorerGame.onLightChangeEvent(intensity, color)
  g_map.setLight({intensity=intensity, color=color})
end

function MapExplorerGame.onSpeedChangeEvent(speed)
  local player = g_game.getLocalPlayer()
  if player then
    player:setSpeed(speed)
    player:setBaseSpeed(speed)
  end
end

function MapExplorerGame.onNoClipChangeEvent(enabled)
  local player = g_game.getLocalPlayer()
  if player then
    player:setNoClipMode(enabled)
  end
end

function MapExplorerGame.onZoomChangeEvent(level, speed)
  -- Zoom logic reads directly from state in hooks
end

-- Expose to global MapExplorer for OTUI compatibility
MapExplorer.onTeleport = MapExplorerGame.onTeleport
MapExplorer.toggleSpawnSimulator = function() SpawnSimulatorUI.toggle() end
MapExplorer.onLoadMap = MapExplorerGame.loadSelectedMap
MapExplorer.resetView = MapExplorerGame.resetView

-- OTUI Callbacks (Delegate to State)
MapExplorer.toggleNoClip = function(enabled) ExplorerState.setNoClipEnabled(enabled) end
MapExplorer.onLightChange = function(value) ExplorerState.setLightIntensity(value) end
MapExplorer.onColorChange = function(value) ExplorerState.setLightColor(value) end
MapExplorer.onSpeedChange = function(value) ExplorerState.setPlayerSpeed(value) end
MapExplorer.onZoomSpeedChange = function(value) ExplorerState.setZoomSpeed(value) end

-- Reset Functions
MapExplorer.resetLight = function() 
  ExplorerState.setLightIntensity(Config.DEFAULT_LIGHT_INTENSITY) 
end
MapExplorer.resetSpeed = function() 
  ExplorerState.setPlayerSpeed(Config.DEFAULT_PLAYER_SPEED) 
end
MapExplorer.resetZoom = function() 
  ExplorerState.setZoomSpeed(Config.DEFAULT_ZOOM_SPEED) 
  MapExplorerGame.resetView()
end

function MapExplorerGame.getSelectedVersion()
  return ExplorerState.getMapVersion()
end

function MapExplorerGame.saveMapState()
  local selectedMapPath = ExplorerState.getMapPath()
  if not selectedMapPath or selectedMapPath == "" then return end
  local player = g_game.getLocalPlayer()
  if not player then return end
  
  local key = Config.SETTINGS_KEYS.MAP_STATE_PREFIX .. g_crypt.md5Encode(selectedMapPath)
  local state = {
    pos = player:getPosition(),
    outfit = player:getOutfit(),
    speed = player:getSpeed(),
    light = ExplorerState.getLightIntensity(),
    color = ExplorerState.getLightColor(),
    zoomSpeed = ExplorerState.getZoomSpeed()
  }
  g_settings.setNode(key, state)
  g_settings.save()
end

function MapExplorerGame.loadMapState()
  local selectedMapPath = ExplorerState.getMapPath()
  if not selectedMapPath or selectedMapPath == "" then return false end
  local key = Config.SETTINGS_KEYS.MAP_STATE_PREFIX .. g_crypt.md5Encode(selectedMapPath)
  local state = g_settings.getNode(key)
  
  if state and state.pos then
    local player = g_game.getLocalPlayer()
    if player then
      player:setPosition(state.pos)
      ExplorerState.setPlayerPosition(state.pos)
      
      if state.outfit then 
          player:setOutfit(state.outfit) 
          ExplorerState.setPlayerOutfit(state.outfit)
      end
      if state.speed then 
         player:setSpeed(state.speed) 
         ExplorerState.setPlayerSpeed(state.speed)
      end
      
      if state.zoomSpeed then 
         ExplorerState.setZoomSpeed(state.zoomSpeed)
      end
      
      if state.light then
         ExplorerState.setLightIntensity(state.light)
      end
      
      if state.color then
         ExplorerState.setLightColor(state.color)
      end
      
      -- Force update map light
      g_map.setLight(ExplorerState.getLight())
      return true
    end
  end
  return false
end

function MapExplorerGame.autoSaveLoop()
  MapExplorerGame.saveMapState()
  scheduleEvent(MapExplorerGame.autoSaveLoop, Config.AUTO_SAVE_INTERVAL_MS)
end
