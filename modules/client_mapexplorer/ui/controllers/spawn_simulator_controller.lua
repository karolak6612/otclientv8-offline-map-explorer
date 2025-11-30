SpawnSimulatorController = {}

-- Dependencies (Global)
local EventBus = _G.ExplorerEventBus
local Events = _G.ExplorerEvents
local ExplorerState = _G.ExplorerState
local Config = _G.ExplorerConfig
local FileBrowserUtils = _G.FileBrowserUtils
local SpawnService = _G.SpawnService

local window = nil
local monsterList = nil
local startButton = nil
local stopButton = nil

function SpawnSimulatorController.init()
  -- Note: Assuming OTUI path will be updated or resolved correctly
  window = g_ui.displayUI('/modules/client_mapexplorer/ui/views/spawn_simulator') 
  window:hide()
  
  monsterList = window:getChildById('monsterList')
  startButton = window:getChildById('startButton')
  stopButton = window:getChildById('stopButton')
  
  if startButton then
    startButton.onClick = function() SpawnService.startSimulation() end
  end
  
  if stopButton then
    stopButton.onClick = function() SpawnService.stopSimulation() end
  end
  
  EventBus.on(Events.SPAWN_LIST_CHANGE, SpawnSimulatorController.onSpawnListChange)
  EventBus.on(Events.SPAWN_SIMULATION_START, SpawnSimulatorController.onSimulationStart)
  EventBus.on(Events.SPAWN_SIMULATION_STOP, SpawnSimulatorController.onSimulationStop)
end

function SpawnSimulatorController.terminate()
  EventBus.off(Events.SPAWN_LIST_CHANGE, SpawnSimulatorController.onSpawnListChange)
  EventBus.off(Events.SPAWN_SIMULATION_START, SpawnSimulatorController.onSimulationStart)
  EventBus.off(Events.SPAWN_SIMULATION_STOP, SpawnSimulatorController.onSimulationStop)
  
  if window then
    window:destroy()
    window = nil
  end
end

function SpawnSimulatorController.toggle()
  if window:isVisible() then
    window:hide()
  else
    window:show()
    window:raise()
    window:focus()
  end
end

function SpawnSimulatorController.onSpawnListChange(monsters, points)
  if not monsterList then return end
  monsterList:destroyChildren()
  
  for _, name in ipairs(monsters) do
    local label = g_ui.createWidget('MonsterListLabel', monsterList)
    label:setText(name)
    
    if SpawnService.getMonsterOutfit(name) then
      label:setColor('green')
    else
      label:setColor('red')
    end
  end
end

function SpawnSimulatorController.onLoadSpawns()
  local root = modules.game_interface.getRootPanel()
  local picker = g_ui.createWidget('SpawnFilePicker', root)
  local fileList = picker:getChildById('fileList')
  
  -- List .xml files in current map directory or root
  local currentPath = ExplorerState.getMapPath()
  local dir = "/"
  if currentPath and currentPath ~= "" then
     dir = FileBrowserUtils.getParentPath(currentPath)
  end
  
  local files = g_resources.listDirectoryFiles(dir, false, false)
  
  for _, file in ipairs(files) do
    if file:ends("-spawn.xml") then
      local widget = g_ui.createWidget('FileBrowserItem', fileList)
      widget:setText(file)
      widget.onDoubleClick = function() 
        SpawnService.loadSpawns(dir .. file)
        picker:destroy()
      end
    end
  end
end

function SpawnSimulatorController.onStartSimulation()
  SpawnService.startSimulation()
end

function SpawnSimulatorController.onStopSimulation()
  SpawnService.stopSimulation()
end

function SpawnSimulatorController.onSimulationStart()
  if startButton then startButton:setEnabled(false) end
  if stopButton then stopButton:setEnabled(true) end
end

function SpawnSimulatorController.onSimulationStop()
  if startButton then startButton:setEnabled(true) end
  if stopButton then stopButton:setEnabled(false) end
end

return SpawnSimulatorController
