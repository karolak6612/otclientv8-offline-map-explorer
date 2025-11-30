MapExplorerUI = {}

local EventBus = dofile('/modules/client_mapexplorer/events/event_bus.lua')
local Events = dofile('/modules/client_mapexplorer/events/event_definitions.lua')
local ExplorerState = dofile('/modules/client_mapexplorer/state/explorer_state.lua')

local mapExplorerWindow
local explorerPanel
local fileList
local statusLabel
local loadButton
local outfitButton

function MapExplorerUI.init()
  g_logger.info("MapExplorerUI: init() called")
  
  -- Create main window (file browser)
  mapExplorerWindow = g_ui.displayUI('mapexplorer')
  mapExplorerWindow:hide()
  
  -- Create explorer panel (tools)
  explorerPanel = g_ui.createWidget('ExplorerPanel', modules.game_interface.getRootPanel())
  explorerPanel:hide()
  MapExplorerUI.explorerPanel = explorerPanel -- Expose for game logic access (legacy/temp)
  
  -- Get widgets
  fileList = mapExplorerWindow:getChildById('fileList')
  loadButton = mapExplorerWindow:getChildById('loadButton')
  outfitButton = explorerPanel:getChildById('outfitButton')
  
  -- Connect buttons
  if loadButton then
    loadButton.onClick = MapExplorerGame.loadSelectedMap
  end
  
  if outfitButton then
    outfitButton.onClick = MapExplorerOutfit.openWindow
  end
  
  -- Initialize FileBrowser
  if fileList then
    FileBrowser.init(fileList)
    FileBrowser.setOnFileSelect(MapExplorerUI.onFileSelected)
  end
  
  -- Subscribe to events
  EventBus.on(Events.LIGHT_CHANGE, MapExplorerUI.onLightChange)
  EventBus.on(Events.PLAYER_SPEED_CHANGE, MapExplorerUI.onSpeedChange)
  EventBus.on(Events.ZOOM_CHANGE, MapExplorerUI.onZoomChange)
  EventBus.on(Events.MAP_LOADED, MapExplorerUI.onMapLoaded)
  EventBus.on(Events.MAP_CLEARED, MapExplorerUI.onMapCleared)
  
  -- Initialize Palette
  MapExplorerUI.initPalette()
end

function MapExplorerUI.initPalette()
  if not explorerPanel then return end
  
  local paletteContainer = explorerPanel:getChildById('paletteContainer')
  if not paletteContainer then return end
  
  paletteContainer:destroyChildren()
  
  -- Generate Tibia 8-bit palette (approximate)
  -- 6x6x6 color cube + grayscale
  for i = 0, 215 do
    local r = (math.floor(i / 36) % 6) * 51
    local g = (math.floor(i / 6) % 6) * 51
    local b = (i % 6) * 51
    local color = string.format("#%02X%02X%02X", r, g, b)
    
    local widget = g_ui.createWidget('UIWidget', paletteContainer)
    widget:setId('color_' .. i)
    widget:setBackgroundColor(color)
    widget:setBorderWidth(1)
    widget:setBorderColor('black')
    widget.onClick = function() 
      ExplorerState.setLightColor(i)
    end
  end
  
  -- Select default
  local currentColor = ExplorerState.getLightColor()
  local defaultWidget = paletteContainer:getChildById('color_' .. currentColor)
  if defaultWidget then
    defaultWidget:setBorderColor('white')
    defaultWidget:setBorderWidth(2)
  end
end

function MapExplorerUI.terminate()
  -- Unsubscribe from events
  EventBus.off(Events.LIGHT_CHANGE, MapExplorerUI.onLightChange)
  EventBus.off(Events.PLAYER_SPEED_CHANGE, MapExplorerUI.onSpeedChange)
  EventBus.off(Events.ZOOM_CHANGE, MapExplorerUI.onZoomChange)
  EventBus.off(Events.MAP_LOADED, MapExplorerUI.onMapLoaded)
  EventBus.off(Events.MAP_CLEARED, MapExplorerUI.onMapCleared)

  if mapExplorerWindow then
    mapExplorerWindow:destroy()
    mapExplorerWindow = nil
  end
  
  if explorerPanel then
    explorerPanel:destroy()
    explorerPanel = nil
  end
end

-- Event Handlers

function MapExplorerUI.onLightChange(intensity, color)
  if not explorerPanel then return end
  local scroll = explorerPanel:getChildById('lightScroll')
  if scroll then
    scroll:setValue(intensity)
  end
  
  -- Update palette selection
  local paletteContainer = explorerPanel:getChildById('paletteContainer')
  if paletteContainer then
     for _, child in pairs(paletteContainer:getChildren()) do
       child:setBorderColor('black')
       child:setBorderWidth(1)
     end
     local selectedWidget = paletteContainer:getChildById('color_' .. color)
     if selectedWidget then
       selectedWidget:setBorderColor('white')
       selectedWidget:setBorderWidth(2)
     end
  end
end

function MapExplorerUI.onSpeedChange(speed)
  if not explorerPanel then return end
  local scroll = explorerPanel:getChildById('speedScroll')
  if scroll then
    scroll:setValue(speed)
  end
end

function MapExplorerUI.onZoomChange(level, speed)
  if not explorerPanel then return end
  local scroll = explorerPanel:getChildById('zoomSpeedScroll')
  if scroll then
    scroll:setValue(speed)
  end
end

function MapExplorerUI.onMapLoaded(path, version)
  MapExplorerUI.setStatus("Map loaded: " .. path)
  MapExplorerUI.hide()
  MapExplorerUI.showTools()
end

function MapExplorerUI.onMapCleared()
  MapExplorerUI.hideTools()
  MapExplorerUI.show()
end

-- Helper functions

function MapExplorerUI.show()
  if mapExplorerWindow then
    mapExplorerWindow:show()
    mapExplorerWindow:raise()
    mapExplorerWindow:focus()
  end
end

function MapExplorerUI.hide()
  if mapExplorerWindow then
    mapExplorerWindow:hide()
  end
end

function MapExplorerUI.showTools()
  if explorerPanel then
    explorerPanel:show()
  end
end

function MapExplorerUI.hideTools()
  if explorerPanel then
    explorerPanel:hide()
  end
end

function MapExplorerUI.toggle()
  if mapExplorerWindow:isVisible() then
    MapExplorerUI.hide()
  else
    MapExplorerUI.show()
  end
end

function MapExplorerUI.onFileSelected(file)
  if file:ends(".otbm") then
    if loadButton then loadButton:setEnabled(true) end
    MapExplorerUI.setStatus("Selected: " .. file)
    -- Update state, which might trigger other things
    ExplorerState.setMapPath(file)
    
    -- Auto-detect version logic is in Game, but maybe should be here or service?
    -- For now, Game handles it via ExplorerState.setMapPath? 
    -- Actually Game.setSelectedMap calls setMapPath AND setMapVersion.
    -- We should call Game.setSelectedMap for now to keep logic there.
    MapExplorerGame.setSelectedMap(file)
  else
    if loadButton then loadButton:setEnabled(false) end
    MapExplorerUI.setStatus("Please select a .otbm file")
  end
end

function MapExplorerUI.setStatus(text)
  g_logger.info("MapExplorerUI Status: " .. text)
end

function MapExplorerUI.setLoadButtonEnabled(enabled)
  if loadButton then
    loadButton:setEnabled(enabled)
  end
end
