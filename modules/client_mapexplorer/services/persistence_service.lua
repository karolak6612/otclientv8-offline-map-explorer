--- PersistenceService
-- Handles saving and restoring of application state (map position, settings).
-- @module PersistenceService
PersistenceService = {}

-- Dependencies (Global)
local Config = _G.ExplorerConfig
local ExplorerState = _G.ExplorerState

function PersistenceService.init()
  g_logger.info("PersistenceService: init() called")
  -- Start auto-save loop
  PersistenceService.autoSaveLoop()
end

function PersistenceService.terminate()
  -- Save on exit
  PersistenceService.saveMapState()
end

function PersistenceService.saveMapState()
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

function PersistenceService.loadMapState()
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

function PersistenceService.autoSaveLoop()
  PersistenceService.saveMapState()
  scheduleEvent(PersistenceService.autoSaveLoop, Config.AUTO_SAVE_INTERVAL_MS)
end

return PersistenceService
