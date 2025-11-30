MapExplorerUI = {}

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
  -- We attach it to the root panel because it uses anchor layout (MainWindow)
  explorerPanel = g_ui.createWidget('ExplorerPanel', modules.game_interface.getRootPanel())
  explorerPanel:hide()
  MapExplorerUI.explorerPanel = explorerPanel -- Expose for game logic access
  
  -- Get widgets from MapExplorerWindow
  fileList = mapExplorerWindow:getChildById('fileList')
  loadButton = mapExplorerWindow:getChildById('loadButton')
  -- statusLabel is not in OTUI, we can add it or just log for now
  -- statusLabel = mapExplorerWindow:getChildById('statusLabel')
  
  -- Get widgets from ExplorerPanel
  outfitButton = explorerPanel:getChildById('outfitButton')
  
  -- Connect buttons
  if loadButton then
    loadButton.onClick = MapExplorerGame.loadSelectedMap
  end
  
  if outfitButton then
    outfitButton.onClick = MapExplorerOutfit.openWindow
  end
  
  -- Initialize FileBrowser with our file list
  if fileList then
    FileBrowser.init(fileList)
    FileBrowser.setOnFileSelect(MapExplorerUI.onFileSelected)
  end
end

function MapExplorerUI.terminate()
  if mapExplorerWindow then
    mapExplorerWindow:destroy()
    mapExplorerWindow = nil
  end
  
  if explorerPanel then
    explorerPanel:destroy()
    explorerPanel = nil
  end
end

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
    MapExplorerGame.setSelectedMap(file)
  else
    if loadButton then loadButton:setEnabled(false) end
    MapExplorerUI.setStatus("Please select a .otbm file")
  end
end

function MapExplorerUI.setStatus(text)
  -- statusLabel is missing in OTUI, so just log it
  g_logger.info("MapExplorerUI Status: " .. text)
end

function MapExplorerUI.setLoadButtonEnabled(enabled)
  if loadButton then
    loadButton:setEnabled(enabled)
  end
end
