MapExplorer = {}

local mapExplorerWindow
local selectedMapPath = ""
local selectedVersion = 1098

-- Available client versions
local CLIENT_VERSIONS = {
  1098, 1099, 1100, 1150, 1200, 1220
}

function init()
  g_settings.setNode('mapexplorer', g_settings.getNode('mapexplorer') or {})
  
  -- Load last used settings
  selectedMapPath = g_settings.getString('mapexplorer/lastMapPath', '')
  selectedVersion = g_settings.getNumber('mapexplorer/lastVersion', 1098)
end

function terminate()
  if mapExplorerWindow then
    mapExplorerWindow:destroy()
  end
end

function show()
  if mapExplorerWindow then
    mapExplorerWindow:raise()
    mapExplorerWindow:focus()
    return
  end

  mapExplorerWindow = g_ui.displayUI('mapexplorer')
  
  -- Populate version selector
  local versionSelector = mapExplorerWindow:getChildById('versionSelector')
  for _, version in ipairs(CLIENT_VERSIONS) do
    versionSelector:addOption(tostring(version))
  end
  
  -- Set last used version
  versionSelector:setCurrentOption(tostring(selectedVersion))
  
  -- Restore last used map path
  if selectedMapPath ~= '' then
    local mapPathEdit = mapExplorerWindow:getChildById('mapPathEdit')
    mapPathEdit:setText(selectedMapPath)
    mapExplorerWindow:getChildById('loadButton'):setEnabled(true)
  end
  
  mapExplorerWindow:show()
  mapExplorerWindow:raise()
  mapExplorerWindow:focus()
end

function hide()
  if mapExplorerWindow then
    mapExplorerWindow:destroy()
    mapExplorerWindow = nil
  end
end

function onBrowseMap()
  local fileDialog = g_platform.openFileDialog("Select OTBM Map File", "OTBM Files (*.otbm)", true)
  
  if fileDialog and fileDialog ~= '' then
    selectedMapPath = fileDialog
    
    local mapPathEdit = mapExplorerWindow:getChildById('mapPathEdit')
    mapPathEdit:setText(selectedMapPath)
    
    local loadButton = mapExplorerWindow:getChildById('loadButton')
    loadButton:setEnabled(true)
    
    local statusLabel = mapExplorerWindow:getChildById('statusLabel')
    statusLabel:setText('Ready to load: ' .. g_resources.fileBasename(selectedMapPath))
    statusLabel:setColor('#88ff88')
  end
end

function onLoadMap()
  if not selectedMapPath or selectedMapPath == '' then
    return
  end
  
  -- Get selected version
  local versionSelector = mapExplorerWindow:getChildById('versionSelector')
  selectedVersion = tonumber(versionSelector:getCurrentOption().text)
  
  -- Save settings
  g_settings.set('mapexplorer/lastMapPath', selectedMapPath)
  g_settings.set('mapexplorer/lastVersion', selectedVersion)
  
  -- Update status
  local statusLabel = mapExplorerWindow:getChildById('statusLabel')
  statusLabel:setText('Loading map, please wait...')
  statusLabel:setColor('#ffff00')
  
  -- Close window
  hide()
  
  -- Load map in next frame to allow UI to update
  scheduleEvent(function()
    loadMapOffline(selectedMapPath, selectedVersion)
  end, 100)
end

function loadMapOffline(otbmPath, clientVersion)
  g_logger.info('MapExplorer: Loading offline map: ' .. otbmPath)
  g_logger.info('MapExplorer: Client version: ' .. clientVersion)
  
  -- Disconnect if online
  if g_game.isOnline() then
    g_game.forceLogout()
    g_game.processGameEnd()
  end
  
  -- Set client version
  g_game.setClientVersion(clientVersion)
  g_game.setProtocolVersion(g_game.getClientProtocolVersion(clientVersion))
  
  -- Load client assets
  local thingsPath = 'things/' .. clientVersion .. '/'
  
  g_logger.info('MapExplorer: Loading OTB: ' .. thingsPath .. 'items.otb')
  if not g_things.loadOtb(thingsPath .. 'items.otb') then
    displayErrorBox('Error', 'Failed to load items.otb for version ' .. clientVersion)
    return false
  end
  
  g_logger.info('MapExplorer: Loading DAT: ' .. thingsPath .. 'Tibia.dat')
  if not g_things.loadDat(thingsPath .. 'Tibia.dat') then
    displayErrorBox('Error', 'Failed to load Tibia.dat for version ' .. clientVersion)
    return false
  end
  
  g_logger.info('MapExplorer: Loading SPR: ' .. thingsPath .. 'Tibia.spr')
  if not g_sprites.loadSpr(thingsPath .. 'Tibia.spr') then
    displayErrorBox('Error', 'Failed to load Tibia.spr for version ' .. clientVersion)
    return false
  end
  
  -- Clean and load map
  g_logger.info('MapExplorer: Cleaning map...')
  g_map.clean()
  
  g_logger.info('MapExplorer: Loading OTBM file...')
  g_map.loadOtbm(otbmPath)
  
  -- Create fake local player
  g_logger.info('MapExplorer: Creating local player...')
  local player = g_game.getLocalPlayer()
  if not player then
    player = LocalPlayer.create()
    g_game.m_localPlayer = player
  end
  
  player:setName("Explorer")
  player:setOutfit({lookType = 128, lookHead = 114, lookBody = 94, lookLegs = 78, lookFeet = 79})
  player:setHealth(150)
  player:setMaxHealth(150)
  player:setMana(90)
  player:setMaxMana(90)
  player:setLevel(8)
  player:setSpeed(220)
  
  -- Position player at map spawn or center
  local spawnPos = findSpawnPosition()
  if spawnPos then
    g_logger.info('MapExplorer: Positioning player at spawn: ' .. spawnPos:toString())
    player:setPosition(spawnPos)
  else
    local mapSize = g_map.getSize()
    local centerPos = Position.create(math.floor(mapSize.width / 2), math.floor(mapSize.height / 2), 7)
    g_logger.info('MapExplorer: Positioning player at map center: ' .. centerPos:toString())
    player:setPosition(centerPos)
  end
  
  -- Set world lighting (full daylight)
  g_logger.info('MapExplorer: Setting world light...')
  g_map.setLight({intensity = 255, color = 215})
  
  -- Enter game state WITHOUT protocol
  g_logger.info('MapExplorer: Entering offline game state...')
  g_game.m_online = true
  g_game.processGameStart()
  
  g_logger.info('MapExplorer: Map loaded successfully!')
  return true
end

function findSpawnPosition()
  -- Try to find a town spawn
  local towns = g_towns.getTowns()
  if #towns > 0 then
    return towns[1]:getPos()
  end
  
  -- Fallback to searching for a walkable tile
  local mapSize = g_map.getSize()
  local centerX = math.floor(mapSize.width / 2)
  local centerY = math.floor(mapSize.height / 2)
  
  -- Search in expanding radius around center
  for radius = 0, 50 do
    for z = 7, 0, -1 do
      for dx = -radius, radius do
        for dy = -radius, radius do
          if math.abs(dx) == radius or math.abs(dy) == radius then
            local pos = Position.create(centerX + dx, centerY + dy, z)
            local tile = g_map.getTile(pos)
            if tile and tile:isWalkable() then
              return pos
            end
          end
        end
      end
    end
  end
  
  return nil
end
