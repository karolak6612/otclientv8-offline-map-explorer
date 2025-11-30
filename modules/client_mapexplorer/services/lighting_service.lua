--- LightingService
-- Controls ambient lighting intensity and color filters.
-- @module LightingService
LightingService = {}

-- Dependencies (Global)
local Config = _G.ExplorerConfig
local ExplorerState = _G.ExplorerState
local EventBus = _G.ExplorerEventBus
local Events = _G.ExplorerEvents

function LightingService.init()
  g_logger.info("LightingService: init() called")
  EventBus.on(Events.LIGHT_CHANGE, LightingService.onLightChangeEvent)
end

function LightingService.terminate()
  EventBus.off(Events.LIGHT_CHANGE, LightingService.onLightChangeEvent)
end

function LightingService.setLightIntensity(value)
  g_logger.info("LightingService: Light intensity changed to: " .. tostring(value))
  ExplorerState.setLightIntensity(value)
end

function LightingService.setLightColor(value)
  g_logger.info("LightingService: Light color changed to: " .. tostring(value))
  ExplorerState.setLightColor(value)
end

function LightingService.onLightChangeEvent(intensity, color)
  g_map.setLight({intensity=intensity, color=color})
end

return LightingService
