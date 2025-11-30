ToolsPanelController = {}

-- Dependencies (Global)
local EventBus = _G.ExplorerEventBus
local Events = _G.ExplorerEvents
local ExplorerState = _G.ExplorerState
local Config = _G.ExplorerConfig
local OutfitService = _G.OutfitService

local explorerToolsPanel = nil

function ToolsPanelController.init()
  g_logger.info("ToolsPanelController: init()")
  
  -- Hook into game events for showing/hiding panel
  connect(g_game, {
    onGameStart = ToolsPanelController.onGameStart,
    onGameEnd = ToolsPanelController.onGameEnd
  })
  
  -- Hook into map events
  EventBus.on(Events.LIGHT_CHANGE, ToolsPanelController.onLightChange)
  EventBus.on(Events.PLAYER_SPEED_CHANGE, ToolsPanelController.onSpeedChange)
  EventBus.on(Events.ZOOM_CHANGE, ToolsPanelController.onZoomChange)
  EventBus.on(Events.MAP_LOADED, ToolsPanelController.onMapLoaded)
  EventBus.on(Events.MAP_CLEARED, ToolsPanelController.onMapCleared)
end

function ToolsPanelController.onGameStart()
  g_logger.info("ToolsPanelController: onGameStart() - Creating dockable panel")
  
  -- Load dockable panel into left panel (following Skills panel pattern)
  local gameInterface = modules.game_interface
  if not explorerToolsPanel then
    -- Get or create first left panel
    local leftPanel = gameInterface.getLeftPanel()
    if not leftPanel then
      g_logger.info("ToolsPanelController: No left panel found, creating one")
      gameInterface.addLeftPanel()
      leftPanel = gameInterface.getLeftPanel()
    end
    
    g_logger.info("ToolsPanelController: Loading UI from OTUI file")
    -- Load MiniWindow into panel
    explorerToolsPanel = g_ui.loadUI('/modules/client_mapexplorer/ui/views/explorer_tools', leftPanel)
    
    if not explorerToolsPanel then
      g_logger.error("ToolsPanelController: Failed to load UI!")
      return
    end
    
    g_logger.info("ToolsPanelController: UI loaded successfully, ID=" .. explorerToolsPanel:getId())
    
    -- Expose for legacy access (MapExplorerGame uses it for teleport values)
    MapExplorerUI.explorerPanel = explorerToolsPanel
    
    -- Setup outfit button callback
    g_logger.info("ToolsPanelController: Setting up outfit button callback")
    local outfitButton = explorerToolsPanel:recursiveGetChildById('outfitButton')
    if outfitButton then
      outfitButton.onClick = OutfitService.openWindow
      g_logger.info("ToolsPanelController: Outfit button callback set successfully")
    else
      g_logger.warning("ToolsPanelController: outfitButton not found!")
    end
    
    -- Initialize color palette
    ToolsPanelController.initPalette()
    
    -- Setup and open the panel
    g_logger.info("ToolsPanelController: Calling setup()")
    explorerToolsPanel:setup()
    
    -- Restore slider values from state
    local lightScroll = explorerToolsPanel:recursiveGetChildById('lightScroll')
    if lightScroll then lightScroll:setValue(ExplorerState.getLightIntensity()) end
    
    local speedScroll = explorerToolsPanel:recursiveGetChildById('speedScroll')
    if speedScroll then speedScroll:setValue(ExplorerState.getPlayerSpeed()) end
    
    local zoomScroll = explorerToolsPanel:recursiveGetChildById('zoomSpeedScroll')
    if zoomScroll then zoomScroll:setValue(ExplorerState.getZoomSpeed()) end
    
    -- Restore Checkbox state
    local scrollCheck = explorerToolsPanel:recursiveGetChildById('scrollFloorCheck')
    if scrollCheck then 
      scrollCheck:setChecked(ExplorerState.isScrollFloorChangeEnabled()) 
    end
    
    g_logger.info("ToolsPanelController: Calling open()")
    explorerToolsPanel:open()
    
    g_logger.info("ToolsPanelController: Panel should now be visible")
    g_logger.info("ToolsPanelController: Panel already exists, opening it")
    explorerToolsPanel:open()
  end
  
  -- Hide close button to prevent accidental closing
  local closeBtn = explorerToolsPanel:getChildById('closeButton')
  if closeBtn then 
    closeBtn:hide() 
  end
end

function ToolsPanelController.onGameEnd()
  -- Hide panel when game ends (don't destroy - maintains state)
  if explorerToolsPanel then
    explorerToolsPanel:close()
  end
end

function ToolsPanelController.terminate()
  EventBus.off(Events.LIGHT_CHANGE, ToolsPanelController.onLightChange)
  EventBus.off(Events.PLAYER_SPEED_CHANGE, ToolsPanelController.onSpeedChange)
  EventBus.off(Events.ZOOM_CHANGE, ToolsPanelController.onZoomChange)
  EventBus.off(Events.MAP_LOADED, ToolsPanelController.onMapLoaded)
  EventBus.off(Events.MAP_CLEARED, ToolsPanelController.onMapCleared)
  
  disconnect(g_game, {
    onGameStart = ToolsPanelController.onGameStart,
    onGameEnd = ToolsPanelController.onGameEnd
  })
  
  if explorerToolsPanel then
    explorerToolsPanel:destroy()
    explorerToolsPanel = nil
  end
  
  MapExplorerUI.explorerPanel = nil
end

function ToolsPanelController.initPalette()
  if not explorerToolsPanel then return end
  
  local paletteContainer = explorerToolsPanel:recursiveGetChildById('paletteContainer')
  if not paletteContainer then 
    g_logger.warning("ToolsPanelController: paletteContainer not found!")
    return 
  end
  
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
      g_logger.info("ToolsPanelController: Color picker clicked, color index: " .. i)
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
  if not explorerToolsPanel then return end
  local scroll = explorerToolsPanel:getChildById('lightScroll')
  if scroll then
    scroll:setValue(intensity)
  end
  
  local paletteContainer = explorerToolsPanel:getChildById('paletteContainer')
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
  if not explorerToolsPanel then return end
  local scroll = explorerToolsPanel:getChildById('speedScroll')
  if scroll then
    scroll:setValue(speed)
  end
end

function ToolsPanelController.onZoomChange(level, speed)
  if not explorerToolsPanel then return end
  local scroll = explorerToolsPanel:getChildById('zoomSpeedScroll')
  if scroll then
    scroll:setValue(speed)
  end
end

function ToolsPanelController.onMapLoaded()
  if explorerToolsPanel then 
    explorerToolsPanel:open()
  end
end

function ToolsPanelController.onMapCleared()
  if explorerToolsPanel then 
    explorerToolsPanel:close()
  end
end

function ToolsPanelController.onClose()
  -- Called when user closes panel via close button
  g_logger.info("ToolsPanelController: Panel closed by user")
end

-- Helper methods for reset buttons
function ToolsPanelController.resetLightScroll()
  if explorerToolsPanel then
    local scroll = explorerToolsPanel:recursiveGetChildById('lightScroll')
    if scroll then scroll:setValue(255) end
  end
end

function ToolsPanelController.resetSpeedScroll()
  if explorerToolsPanel then
    local scroll = explorerToolsPanel:recursiveGetChildById('speedScroll')
    if scroll then scroll:setValue(200) end
  end
end

function ToolsPanelController.resetZoomSpeedScroll()
  if explorerToolsPanel then
    local scroll = explorerToolsPanel:recursiveGetChildById('zoomSpeedScroll')
    if scroll then scroll:setValue(1) end
  end
end

-- Event handler for zoom speed changes (with logging)
function ToolsPanelController.onZoomSpeedChange(value)
  g_logger.info("ToolsPanelController: Zoom speed changed to: " .. value)
  ExplorerState.setZoomSpeed(value)
end

return ToolsPanelController
