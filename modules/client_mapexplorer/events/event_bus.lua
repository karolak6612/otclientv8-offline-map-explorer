-- Event Bus for MapExplorer
-- Decoupled communication between modules

if _G.ExplorerEventBus then
  return _G.ExplorerEventBus
end

local EventBus = {}
local listeners = {}

function EventBus.on(event, callback)
  if not event or not callback then
    g_logger.error("EventBus: Invalid arguments to on()")
    return
  end
  
  if not listeners[event] then 
    listeners[event] = {} 
  end
  
  table.insert(listeners[event], callback)
end

function EventBus.off(event, callback)
  if not listeners[event] then return end
  
  for i, cb in ipairs(listeners[event]) do
    if cb == callback then
      table.remove(listeners[event], i)
      return
    end
  end
end

function EventBus.emit(event, ...)
  if listeners[event] then
    -- Copy list to allow modification during emission (e.g. unsubscribe)
    local callbacks = {}
    for _, cb in ipairs(listeners[event]) do
      table.insert(callbacks, cb)
    end
    
    for _, callback in ipairs(callbacks) do
      local status, err = pcall(callback, ...)
      if not status then
        g_logger.error("EventBus: Error in listener for " .. event .. ": " .. tostring(err))
      end
    end
  end
end

-- Debug helper
function EventBus.getListenerCount(event)
  if not listeners[event] then return 0 end
  return #listeners[event]
end

_G.ExplorerEventBus = EventBus
return EventBus
