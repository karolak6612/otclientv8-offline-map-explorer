--- OutfitService
-- Handles outfit selection, validation, and application.
-- @module OutfitService
OutfitService = {}

-- Dependencies (Global)
local Config = _G.ExplorerConfig

function OutfitService.init()
  g_logger.info("OutfitService: init() called")
end

function OutfitService.terminate()
  -- Cleanup if needed
end

function OutfitService.openWindow()
  g_logger.info("OutfitService: openWindow called")
  local player = g_game.getLocalPlayer()
  if not player then return end
  
  -- Prepare lists for outfit window
  local outfits = OutfitService.getValidOutfits()
  local mounts = {{0, "None"}} -- TODO: Populate mounts if needed
  local wings = {{0, "None"}}
  local auras = {{0, "None"}}
  local healthBars = {{0, "None"}}
  local manaBars = {{0, "None"}}
  
  -- CRITICAL: Shader list must include "outfit_default"
  local shaders = {
    {0, "Default", "outfit_default"},
    {1, "None", "no_shader"}
  }
  
  -- Get current outfit
  local currentOutfit = player:getOutfit()
  OutfitService.ensureOutfitDefaults(currentOutfit)
  
  -- Validate addon value
  local maxAddons = OutfitService.getMaxAddonsForOutfit(currentOutfit.type)
  if currentOutfit.addons > maxAddons then
    currentOutfit.addons = maxAddons
  end
  
  -- Call outfit window
  local status, err = pcall(function()
    if modules.game_outfit then
      modules.game_outfit.create(currentOutfit, outfits, mounts, wings, auras, shaders, healthBars, manaBars)
    end
  end)
  
  if not status then
    displayErrorBox("Outfit Error", "Failed to open outfit window.")
  end
end

function OutfitService.openWindowWithCallback(currentOutfit, callback)
  g_logger.info("OutfitService: openWindowWithCallback called")
  
  -- Prepare lists for outfit window
  local outfits = OutfitService.getValidOutfits()
  local mounts = {{0, "None"}}
  local wings = {{0, "None"}}
  local auras = {{0, "None"}}
  local healthBars = {{0, "None"}}
  local manaBars = {{0, "None"}}
  
  local shaders = {
    {0, "Default", "outfit_default"},
    {1, "None", "no_shader"}
  }
  
  OutfitService.ensureOutfitDefaults(currentOutfit)
  
  local maxAddons = OutfitService.getMaxAddonsForOutfit(currentOutfit.type)
  if currentOutfit.addons > maxAddons then
    currentOutfit.addons = maxAddons
  end
  
  local status, err = pcall(function()
    if modules.game_outfit then
      local window = modules.game_outfit.create(currentOutfit, outfits, mounts, wings, auras, shaders, healthBars, manaBars)
      -- Hook the "Ok" button or whatever mechanism game_outfit uses
      -- Note: game_outfit usually applies changes directly to local player.
      -- If we want a callback, we might need to hook g_game.changeOutfit or similar.
      -- For now, we'll assume game_outfit calls g_game.changeOutfit, which we hooked in PlayerService/Game.
      
      -- If we need to capture the result for a specific purpose (like SpawnSimulator),
      -- we might need to temporarily override the global hook or pass a callback if game_outfit supports it.
      -- Standard game_outfit doesn't support callback arg.
      
      -- Workaround: We can't easily get a callback from standard game_outfit without modifying it.
      -- But for SpawnSimulator, we might just need to know the outfit was selected.
      -- If this is for SpawnSimulator, we might need a custom outfit window or accept that it changes the player's outfit.
      
      if callback then
         -- This is tricky with standard game_outfit. 
         -- We might need to listen to the next outfit change event.
         local connection = nil
         connection = connect(g_game, { onOpenOutfitWindow = function() end }) -- Placeholder
         -- Actually, we can hook the global changeOutfit again temporarily?
         -- Or just let the user change their outfit, then "Copy from Player" in the simulator.
      end
    end
  end)
end

function OutfitService.applyOutfit(player, outfit)
  if not player then return end
  
  g_logger.info(string.format("Setting outfit: type=%d", outfit.type))
  
  -- Check validity
  if not OutfitService.isValidOutfit(outfit.type) then
    g_logger.error("Invalid outfit type: " .. tostring(outfit.type))
    displayInfoBox("Outfit Error", "Invalid outfit type selected.")
    return
  end
  
  local status, err = pcall(function() 
    player:setOutfit(outfit)
  end)
  
  if not status then
    g_logger.error("Failed to set outfit: " .. tostring(err))
    displayInfoBox("Outfit Error", "Failed to change outfit.")
  end
end

function OutfitService.ensureOutfitDefaults(outfit)
  outfit.type = outfit.type or 0
  outfit.head = outfit.head or 0
  outfit.body = outfit.body or 0
  outfit.legs = outfit.legs or 0
  outfit.feet = outfit.feet or 0
  outfit.addons = outfit.addons or 0
  outfit.mount = outfit.mount or 0
  outfit.wings = outfit.wings or 0
  outfit.aura = outfit.aura or 0
  outfit.shader = outfit.shader or "outfit_default"
  outfit.healthBar = outfit.healthBar or 0
  outfit.manaBar = outfit.manaBar or 0
end

function OutfitService.getValidOutfits()
  local outfits = {}
  local consecutiveInvalid = 0
  
  -- Scan for valid outfits
  -- Limit to 2000 or until 10 consecutive failures
  for i = 1, Config.MAX_OUTFIT_SCAN do
    if OutfitService.isValidOutfit(i) then
      table.insert(outfits, {i, "Outfit " .. i})
      consecutiveInvalid = 0
    else
      consecutiveInvalid = consecutiveInvalid + 1
    end
    
    if consecutiveInvalid >= Config.CONSECUTIVE_INVALID_LIMIT then
      break
    end
  end
  
  return outfits
end

function OutfitService.isValidOutfit(typeId)
  local status, result = pcall(function()
    return g_things.getThingType(typeId, ThingCategoryCreature)
  end)
  
  if not status or not result then return false end
  
  -- Check if we got a valid thing type (not the null one)
  if result:getId() ~= typeId then return false end
  
  return true
end

function OutfitService.getMaxAddonsForOutfit(typeId)
  -- Simplified: assume 3 addons (0, 1, 2, 3)
  return Config.MAX_ADDONS
end

return OutfitService
