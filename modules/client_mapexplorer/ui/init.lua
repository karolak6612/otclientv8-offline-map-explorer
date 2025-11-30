-- ui/init.lua
-- Phase 4: UI & Logic Separation
-- Orchestrates UI controllers and provides legacy compatibility

-- Dependencies (Global)
local MapBrowserController = _G.MapBrowserController
local ToolsPanelController = _G.ToolsPanelController
local SpawnSimulatorController = _G.SpawnSimulatorController

-- Legacy Globals Shim
_G.MapExplorerUI = {}

function _G.MapExplorerUI.init()
  g_logger.info("MapExplorerUI: init() called (via ui/init.lua)")
  MapBrowserController.init()
  ToolsPanelController.init()
  SpawnSimulatorController.init()
end

function _G.MapExplorerUI.terminate()
  MapBrowserController.terminate()
  ToolsPanelController.terminate()
  SpawnSimulatorController.terminate()
end

-- MapBrowser Methods
_G.MapExplorerUI.show = MapBrowserController.show
_G.MapExplorerUI.hide = MapBrowserController.hide
_G.MapExplorerUI.toggle = MapBrowserController.toggle
_G.MapExplorerUI.setStatus = function(text) g_logger.info("MapExplorerUI Status: " .. text) end
_G.MapExplorerUI.showTools = ToolsPanelController.onMapLoaded
_G.MapExplorerUI.hideTools = ToolsPanelController.onMapCleared

-- Expose ToolsPanelController globally for OTUI callbacks
_G.ToolsPanelController = ToolsPanelController

-- SpawnSimulator Globals
_G.SpawnSimulatorUI = {}
_G.SpawnSimulatorUI.init = function() end -- Handled by MapExplorerUI.init
_G.SpawnSimulatorUI.terminate = function() end -- Handled by MapExplorerUI.terminate
_G.SpawnSimulatorUI.toggle = SpawnSimulatorController.toggle
_G.SpawnSimulatorUI.onLoadSpawns = SpawnSimulatorController.onLoadSpawns
_G.SpawnSimulatorUI.onStartSimulation = SpawnSimulatorController.onStartSimulation
_G.SpawnSimulatorUI.onStopSimulation = SpawnSimulatorController.onStopSimulation

return _G.MapExplorerUI
