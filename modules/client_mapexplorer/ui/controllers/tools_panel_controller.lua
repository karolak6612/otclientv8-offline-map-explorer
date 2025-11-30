ToolsPanelController = {}

-- Dependencies (Global)
local EventBus = _G.ExplorerEventBus
local Events = _G.ExplorerEvents
local ExplorerState = _G.ExplorerState
local Config = _G.ExplorerConfig

local panel = nil

function ToolsPanelController.init()
  panel = g_ui.createWidget('ExplorerPanel', modules.game_interface.getRootPanel())
  panel:hide()
  
  -- Expose for legacy access (MapExplorerGame uses it for teleport values)
  -- Ideally we should expose getters in Controller, but for now this is fine.
  MapExplorerUI.explorerPanel = panel 
  
  local outfitButton = panel:getChildById('outfitButton')
  if outfitButton then
    outfitButton.onClick = MapExplorerOutfit.openWindow
  end
  
  ToolsPanelController.initPalette()
  
  EventBus.on(Events.LIGHT_CHANGE, ToolsPanelController.onLightChange)
  EventBus.on(Events.PLAYER_SPEED_CHANGE, ToolsPanelController.onSpeedChange)
  EventBus.on(Events.ZOOM_CHANGE, ToolsPanelController.onZoomChange)
  EventBus.on(Events.MAP_LOADED, ToolsPanelController.onMapLoaded)
  EventBus.on(Events.MAP_CLEARED, ToolsPanelController.onMapCleared)
end

function ToolsPanelController.terminate()
  EventBus.off(Events.LIGHT_CHANGE, ToolsPanelController.onLightChange)
  EventBus.off(Events.PLAYER_SPEED_CHANGE, ToolsPanelController.onSpeedChange)
  EventBus.off(Events.ZOOM_CHANGE, ToolsPanelController.onZoomChange)
  EventBus.off(Events.MAP_LOADED, ToolsPanelController.onMapLoaded)
  EventBus.off(Events.MAP_CLEARED, ToolsPanelController.onMapCleared)
  
  if panel then
    panel:destroy()
    panel = nil
  end
end

function ToolsPanelController.initPalette()
  if not panel then return end
  
  local paletteContainer = panel:getChildById('paletteContainer')
  if not paletteContainer then return end
  
  paletteContainer:destroyChildren()
  
  for i = 0, Config.PALETTE_COLOR_COUNT - 1 do
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
  
  local currentColor = ExplorerState.getLightColor()
  local defaultWidget = paletteContainer:getChildById('color_' .. currentColor)
  if defaultWidget then
    defaultWidget:setBorderColor('white')
    defaultWidget:setBorderWidth(2)
  end
end

function ToolsPanelController.onLightChange(intensity, color)
  if not panel then return end
  local scroll = panel:getChildById('lightScroll')
  if scroll then
    scroll:setValue(intensity)
  end
  
  local paletteContainer = panel:getChildById('paletteContainer')
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

function ToolsPanelController.onSpeedChange(speed)
  if not panel then return end
  local scroll = panel:getChildById('speedScroll')
  if scroll then
    scroll:setValue(speed)
  end
end

function ToolsPanelController.onZoomChange(level, speed)
  if not panel then return end
  local scroll = panel:getChildById('zoomSpeedScroll')
  if scroll then
    scroll:setValue(speed)
  end
end

function ToolsPanelController.onMapLoaded()
  if panel then panel:show() end
end

function ToolsPanelController.onMapCleared()
  if panel then panel:hide() end
end

return ToolsPanelController
