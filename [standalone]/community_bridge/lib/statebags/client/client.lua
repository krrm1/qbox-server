ClientStateBag = {}

---Gets an entity from a statebag name
---@param entityId string The entity ID or statebag name
---@return number|nil entity The entity handle or nil if not found
local function getStateBagEntity(entityId)
    local _entity = GetEntityFromStateBagName(entityId)
    return _entity
end

local function getPlayerFromStateBagName(stateBagName)
    return getPlayerFromStateBagName(stateBagName)
end

---Adds a handler for entity statebag changes
---@param keyName string The statebag key to watch for changes
---@param entityId string|nil The specific entity ID to watch, or nil for all entities
---@param callback function The callback function to handle changes (function(entityId, key, value, lastValue, replicated))
---@return number handler The handler ID
function ClientStateBag.AddEntityChangeHandler(keyName, entityId, callback)
    return AddStateBagChangeHandler(keyName, entityId or nil, function(bagName, key, value, lastValue, replicated)
        local entity = getStateBagEntity(bagName)
        if not DoesEntityExist(entity) then return end
        if entity then
            return callback(entity, key, value, lastValue, replicated)
        end
    end)
end

---Adds a handler for player statebag changes
---@param keyName string The statebag key to watch for changes
---@param filter boolean|nil If true, only watch for changes from the current player
---@param callback function The callback function to handle changes (function(playerId, key, value, lastValue, replicated))
---@return number handler The handler ID
function ClientStateBag.AddPlayerChangeHandler(keyName, filter, callback)
    return AddStateBagChangeHandler(keyName, filter and ("player:%s"):format(GetPlayerServerId(PlayerId())) or nil,
        function(bagName, key, value, lastValue, replicated)
            local actualPlayerId = getPlayerFromStateBagName(bagName)
            if DoesEntityExist(actualPlayerId) and (actualPlayerId ~= PlayerPedId()) then -- you cant have a statebag value if you are not the player
                return false
            end
            if actualPlayerId and actualPlayerId ~= 0 then
                return callback(tonumber(actualPlayerId), key, value, lastValue, replicated)
            end
        end)
end

return ClientStateBag
