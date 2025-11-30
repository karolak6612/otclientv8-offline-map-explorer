if _G.FileBrowserWidget then
  return _G.FileBrowserWidget
end

_G.FileBrowserWidget = {}

-- Dependencies (Global)
local Config = _G.ExplorerConfig
local ExplorerState = _G.ExplorerState
local FileBrowserUtils = _G.FileBrowserUtils

local fileList = nil
local onFileSelectCallback = nil

function _G.FileBrowserWidget.init(listWidget)
  fileList = listWidget
  
  if not fileList then
    g_logger.error("FileBrowserWidget: No list widget provided")
    return
  end
  
  -- Initial path
  _G.FileBrowserWidget.setPath(g_resources.getWorkDir() .. Config.DEFAULT_MAP_BROWSER_PATH)
end

function _G.FileBrowserWidget.setPath(path)
  if not g_resources.directoryExists(path) then
    return
  end
  
  path = FileBrowserUtils.normalizePath(path)
  
  ExplorerState.setBrowserPath(path)
  _G.FileBrowserWidget.refresh()
end

function _G.FileBrowserWidget.refresh()
  if not fileList then return end
  
  local currentPath = ExplorerState.getBrowserPath()
  fileList:destroyChildren()
  
  -- Add ".." if not root
  if currentPath ~= "/" and currentPath ~= "" then
    local widget = g_ui.createWidget('FileBrowserItem', fileList)
    widget:setText("..")
    widget.isDir = true
    widget.fullPath = FileBrowserUtils.getParentPath(currentPath)
    widget:setId("parent_dir")
    widget.onDoubleClick = function() _G.FileBrowserWidget.setPath(widget.fullPath) end
  end
  
  local files = g_resources.listDirectoryFiles(currentPath, false, false)
  files = FileBrowserUtils.sortFiles(files, currentPath)
  
  for _, file in ipairs(files) do
    local fullPath = currentPath .. file
    local isDir = g_resources.directoryExists(fullPath)
    local isOtbm = file:ends(".otbm")
    
    if isDir or isOtbm then
      local widget = g_ui.createWidget('FileBrowserItem', fileList)
      widget:setText(file)
      widget.fullPath = fullPath
      widget.isDir = isDir
      
      if isDir then
        widget:setText("[DIR] " .. file)
        widget.onDoubleClick = function() _G.FileBrowserWidget.setPath(fullPath) end
      else
        widget.onDoubleClick = function() 
          if onFileSelectCallback then
            onFileSelectCallback(fullPath)
          end
        end
      end
    end
  end
end

function _G.FileBrowserWidget.goUp()
  local currentPath = ExplorerState.getBrowserPath()
  local newPath = FileBrowserUtils.getParentPath(currentPath)
  _G.FileBrowserWidget.setPath(newPath)
end

function _G.FileBrowserWidget.setOnFileSelect(callback)
  onFileSelectCallback = callback
end

return _G.FileBrowserWidget
