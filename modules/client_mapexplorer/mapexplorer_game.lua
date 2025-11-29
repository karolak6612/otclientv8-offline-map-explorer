MapExplorerGame = {}

local selectedMapPath = ""
local selectedVersion = 1098
local lastPlayerPos = nil

function MapExplorerGame.init()
  g_logger.info("MapExplorerGame: init() called")
  
  -- Load last used settings
  selectedMapPath = g_settings.getString('mapexplorer/lastMapPath', '')
  
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
end

function MapExplorerGame.terminate()
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
  MapExplorerUI.hide() -- Hide file browser if open
  MapExplorerUI.showTools() -- Show tools panel
  
  -- Hide EnterGame window
  if modules.client_entergame and modules.client_entergame.EnterGame then
    modules.client_entergame.EnterGame.hide()
  end
  
  -- Disable game_walking module to prevent conflict
  if modules.game_walking then
    g_modules.ensureModuleLoaded('game_walking') -- Ensure it's loaded so we can unload it properly? No, just check if loaded.
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
end

function MapExplorerGame.onGameEnd()
  g_logger.info("MapExplorerGame: onGameEnd")
  MapExplorerGame.saveMapState()
  MapExplorerUI.hideTools()
  
  -- Re-enable game_walking module
  if modules.game_walking then
     modules.game_walking.init()
  end
end

function MapExplorerGame.onGameEnd()
  g_logger.info("MapExplorerGame: onGameEnd")
  MapExplorerGame.saveMapState()
  MapExplorerUI.hideTools()
end

function MapExplorerGame.setSelectedMap(path)
  selectedMapPath = path
  g_settings.set('mapexplorer/lastMapPath', path)
end

-- Compatibility with EnterGame
MapExplorer = {}

function MapExplorer.show(version)
  selectedVersion = version or 1098
  MapExplorerUI.show()
end

function MapExplorer.hide()
  MapExplorerUI.hide()
end

function MapExplorerGame.loadSelectedMap()
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
    
    g_game.setClientVersion(selectedVersion)
    g_game.setProtocolVersion(g_game.getClientProtocolVersion(selectedVersion))
    
    -- Load Assets (Exact copy from mapexplorer_temp.lua)
    local dataDir = '/data/things/' .. selectedVersion
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
    
    -- Load OTBM (using pcall as it might raise error, and returns nil on success)
    local status, err = pcall(function()
      g_map.loadOtbm(mapPath)
    end)
    
    if not status then
      g_logger.error("Failed to load map: " .. tostring(err))
      MapExplorerUI.setStatus("Failed to load map: " .. tostring(err))
      return
    end
    
    MapExplorerUI.setStatus("Map loaded!")
    MapExplorerUI.hide()
    MapExplorerUI.showTools() -- Show the tools panel
    
    -- Set initial position (center of map or saved pos)
    local player = g_game.getLocalPlayer()
    if not player then
      player = LocalPlayer.create()
      player:setOfflineMode(true)
      player:setName("MapExplorer")
      g_game.setLocalPlayer(player)
    end
    
    -- Reset light to default before loading state
    currentLight = 255
    
    -- Try to load state
    if not MapExplorerGame.loadMapState() then
      -- Try to find a valid position if no state loaded
      local pos = MapExplorerGame.findSpawnPosition()
      if not pos then
         -- Fallback to center if no valid tile found
         local mapSize = g_map.getSize()
         pos = {x = math.floor(mapSize.width / 2), y = math.floor(mapSize.height / 2), z = 7}
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
    g_map.setLight({intensity = currentLight, color = 215})
    if MapExplorerUI.explorerPanel then
        MapExplorerUI.explorerPanel:getChildById('lightScroll'):setValue(currentLight)
    end
    
    -- Start game interface
    g_game.processGameStart()
    
    -- Force minimap generation
    if g_minimap then
      g_minimap.clean()
      g_minimap.generateFromMap()
    end
  end, 100)
end

-- Remove local currentLight declaration here as it's now used above, 
-- but we need to ensure it's declared at module level if not already.
-- Checking file content, it was declared at line 257 in previous read, 
-- but I am replacing the block that includes line 257.
-- Wait, line 257 was `local currentLight = 255`.
-- I need to make sure `currentLight` is available to `loadMapState` which is defined later?
-- No, `loadMapState` is defined later.
-- But `loadSelectedMap` uses `currentLight`.
-- `currentLight` must be upvalue.
-- In the previous file content, `local currentLight = 255` was at line 257, AFTER `loadSelectedMap` (lines 153-255).
-- This means `loadSelectedMap` was using a global or nil `currentLight`?
-- No, Lua functions capture upvalues. If `currentLight` is defined AFTER `loadSelectedMap`, `loadSelectedMap` can't see it unless it's global?
-- Wait, if `currentLight` is local at file scope but defined AFTER the function, the function can't see it?
-- Actually, in Lua, if I define `local currentLight` after, the function defined before will NOT see it.
-- So `currentLight` inside `loadSelectedMap` (if I used it) would be nil or global.
-- I need to move `local currentLight = 255` to the TOP of the file.
-- I will check where `currentLight` is defined.
-- In step 750 read, `local currentLight = 255` is at line 257. `loadSelectedMap` ends at line 255.
-- So `loadSelectedMap` could NOT access `currentLight`!
-- That explains why I hardcoded 255 in `loadSelectedMap`.
-- I must move `local currentLight = 255` to the top of the file.

function MapExplorerGame.teleportTo(pos)
  local player = g_game.getLocalPlayer()
  if not player then return end
  
  -- Remove from old tile
  local oldTile = g_map.getTile(player:getPosition())
  if oldTile then oldTile:removeThing(player) end
  
  player:setPosition(pos)
  
  local newTile = g_map.getTile(pos)
  if newTile then 
    newTile:addThing(player, -1)
  end
  g_map.setCentralPosition(pos)
  lastPlayerPos = pos
end

function MapExplorerGame.floorUp()
  local player = g_game.getLocalPlayer()
  if not player then return end
  local pos = player:getPosition()
  pos.z = pos.z - 1
  if pos.z < 0 then pos.z = 0 end
  MapExplorerGame.teleportTo(pos)
end

function MapExplorerGame.floorDown()
  local player = g_game.getLocalPlayer()
  if not player then return end
  local pos = player:getPosition()
  pos.z = pos.z + 1
  if pos.z > 15 then pos.z = 15 end
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
  end
end

function MapExplorerGame.onSpeedChange(value)
  local player = g_game.getLocalPlayer()
  if player then
    player:setSpeed(value)
    player:setBaseSpeed(value)
  end
end

function MapExplorerGame.onLightChange(value)
  currentLight = value
  g_map.setLight({intensity = value, color = 215})
end

-- Expose to global MapExplorer for OTUI compatibility
MapExplorer.onTeleport = MapExplorerGame.onTeleport
MapExplorer.toggleNoClip = MapExplorerGame.toggleNoClip
MapExplorer.onSpeedChange = MapExplorerGame.onSpeedChange
MapExplorer.onLightChange = MapExplorerGame.onLightChange

function MapExplorerGame.saveMapState()
  if not selectedMapPath or selectedMapPath == "" then return end
  local player = g_game.getLocalPlayer()
  if not player then return end
  
  local key = 'map_state_' .. g_crypt.md5Encode(selectedMapPath)
  local state = {
    pos = player:getPosition(),
    outfit = player:getOutfit(),
    speed = player:getSpeed(),
    light = currentLight
  }
  g_settings.setNode(key, state)
  g_settings.save()
end

function MapExplorerGame.loadMapState()
  if not selectedMapPath or selectedMapPath == "" then return false end
  local key = 'map_state_' .. g_crypt.md5Encode(selectedMapPath)
  local state = g_settings.getNode(key)
  
  if state and state.pos then
    local player = g_game.getLocalPlayer()
    if player then
      player:setPosition(state.pos)
      if state.outfit then 
          player:setOutfit(state.outfit) 
      end
      if state.speed then 
         player:setSpeed(state.speed) 
         if MapExplorerUI.explorerPanel then
            MapExplorerUI.explorerPanel:getChildById('speedScroll'):setValue(state.speed)
         end
      end
      if state.light then
         currentLight = state.light
         g_map.setLight({intensity = currentLight, color = 215})
         if MapExplorerUI.explorerPanel then
            MapExplorerUI.explorerPanel:getChildById('lightScroll'):setValue(currentLight)
         end
      end
      return true
    end
  end
  return false
end

function MapExplorerGame.autoSaveLoop()
  MapExplorerGame.saveMapState()
  scheduleEvent(MapExplorerGame.autoSaveLoop, 5000) -- Save every 5 seconds
end
