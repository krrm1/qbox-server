Utility = Utility or Require("lib/utility/client/utility.lua")
Ids = Ids or Require("lib/utility/shared/ids.lua")
Point = Point or Require("lib/points/client/points.lua")
ClientEntityActions = ClientEntityActions or Require("lib/entities/client/client_entity_actions_ext.lua") -- Added

local Entities = {} -- Stores entity data received from server
ClientEntity = {} -- Renamed from BaseEntity

local function SpawnEntity(entityData)
    entityData = entityData and entityData.args
    if entityData.spawned and DoesEntityExist(entityData.spawned) then return end -- Already spawned
    -- for k, v in pairs(entityData.args) do
    --     print(string.format("SpawnEntity %s: %s", k, v))
    -- end
    local model = entityData.model and type(entityData.model) == 'string' and GetHashKey(entityData.model) or entityData.model
    if model and not Utility.LoadModel(model) then
        print(string.format("[ClientEntity] Failed to load model %s for entity %s", entityData.model, entityData.id))
        return
    end

    local entity = nil
    local coords = entityData.coords
    local rotation = entityData.rotation or vector3(0.0, 0.0, 0.0) -- Default rotation if not provided

    if entityData.entityType == 'object' then
        entity = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
        SetEntityRotation(entity, rotation.x, rotation.y, rotation.z, 2, true)
    elseif entityData.entityType == 'ped' then
        entity = CreatePed(4, model, coords.x, coords.y, coords.z, type(rotation) == 'number' and rotation or rotation.z, false, false)
    elseif entityData.entityType == 'vehicle' then
        entity = CreateVehicle(model, coords.x, coords.y, coords.z, type(rotation) == 'number' and rotation or rotation.z, false, false)
    else
        print(string.format("[ClientEntity] Unknown entity type '%s' for entity %s", entityData.entityType, entityData.id))
    end
    if entity and model then
        entityData.spawned = entity
        SetModelAsNoLongerNeeded(model)
        SetEntityAsMissionEntity(entity, true, true)
        FreezeEntityPosition(entity, true)
    else
        SetModelAsNoLongerNeeded(model)
    end
    if entityData.OnSpawn then
        entityData.OnSpawn(entityData)
    end
end

local function RemoveEntity(entityData)
    entityData = entityData and entityData.args or entityData
    if not entityData then return end
    ClientEntityActions.StopAction(entityData.id)
    if entityData.spawned and DoesEntityExist(entityData.spawned) then
        local entityHandle = entityData.spawned
        entityData.spawned = nil
        SetEntityAsMissionEntity(entityHandle, false, false)
        DeleteEntity(entityHandle)
    end
    if entityData.OnRemove then
        entityData.OnRemove(entityData)
    end
end

--- Registers an entity received from the server and sets up proximity spawning.
-- @param entityData table Data received from the server via 'community_bridge:client:CreateEntity'
function ClientEntity.Create(entityData)
    entityData.id = entityData.id or Ids.CreateUniqueId(Entities)
    if Entities[entityData.id] then return Entities[entityData.id] end -- Already registered
    Entities[entityData.id] = entityData
    return Point.Register(entityData.id, entityData.coords, entityData.spawnDistance or 50.0, entityData, SpawnEntity, RemoveEntity, function() end)
end

--Depricated use ClientEntity.Create instead
--- Registers an entity and spawns it in the world if not already spawned.
ClientEntity.Register = ClientEntity.Create


function ClientEntity.CreateBulk(entities)
    local registeredEntities = {}
    for _, entityData in pairs(entities) do
        local entity = ClientEntity.Create(entityData)
        registeredEntities[entity.id] = entity
    end
    return registeredEntities
end

-- Depricated use ClientEntity.CreateBulk instead
ClientEntity.RegisterBulk = ClientEntity.CreateBulk



--- Unregisters an entity and removes it from the world if spawned.
-- @param id string|number The ID of the entity to unregister.
function ClientEntity.Destroy(id)
    local entityData = Entities[id]
    if not entityData then return end

    Point.Remove(id)
    RemoveEntity(entityData)
    Entities[id] = nil
end
ClientEntity.Unregister = ClientEntity.Destroy


--- Updates the data for a registered entity.
-- @param id string|number The ID of the entity to update.
-- @param data table The data fields to update.
function ClientEntity.Update(id, data)
    local entityData = Entities[id]
    -- print(string.format("[ClientEntity] Updating entity %s", id))
    if not entityData then return end

    local needsPointUpdate = false
    for key, value in pairs(data) do
        if key == 'coords' and #(entityData.coords - value) > 0.1 then
             needsPointUpdate = true
        end
        if key == 'spawnDistance' and entityData.spawnDistance ~= value then
             needsPointUpdate = true
        end
        entityData[key] = value
    end

    -- If entity is currently spawned, apply updates
    if entityData.spawned and DoesEntityExist(entityData.spawned) then
        if data.coords then
            SetEntityCoords(entityData.spawned, entityData.coords.x, entityData.coords.y, entityData.coords.z, false, false, false, true)
        end
        if data.rotation then
             if entityData.entityType == 'object' then
                 SetEntityRotation(entityData.spawned, entityData.rotation.x, entityData.rotation.y, entityData.rotation.z, 2, true)
             else -- Ped/Vehicle heading
                 SetEntityHeading(entityData.spawned, type(entityData.rotation) == 'number' and entityData.rotation or entityData.rotation.z)
             end
        end
        if data.freeze ~= nil then
            FreezeEntityPosition(entityData.spawned, data.freeze)
        end
        -- Add other updatable properties as needed
    end

    -- Update Point registration if coords or distance changed
    if needsPointUpdate then
        Point.Remove(id)
        Point.Register(
            entityData.id,
            entityData.coords,
            entityData.spawnDistance or 50.0,
            SpawnEntity,
            RemoveEntity,
            nil,
            entityData
        )
    end

    if entityData.OnUpdate and type(entityData.OnUpdate) == 'function' then
        entityData.OnUpdate(entityData, data)
    end
end

function ClientEntity.Get(id)
    return Entities[id]
end

function ClientEntity.GetAll()
    return Entities
end

function ClientEntity.RegisterAction(name, func)
    ClientEntityActions.RegisterAction(name, func)
end

function ClientEntity.OnCreate(_type, func)
    ClientEntity.OnCreates = ClientEntity.OnCreates or {}
    if not ClientEntity.OnCreates[_type] then
        ClientEntity.OnCreates[_type] = {}
    end
    table.insert(ClientEntity.OnCreates[_type], func)
end

-- Network Event Handlers
RegisterNetEvent("community_bridge:client:CreateEntity", function(entityData)
    ClientEntity.Create(entityData)
end)

RegisterNetEvent("community_bridge:client:CreateEntities", function(entities)
    ClientEntity.CreateBulk(entities)
end)

RegisterNetEvent("community_bridge:client:DeleteEntity", function(id)
    ClientEntity.Unregister(id)
end)

RegisterNetEvent("community_bridge:client:UpdateEntity", function(id, data)
    ClientEntity.Update(id, data)
end)

-- New handler for entity actions
RegisterNetEvent("community_bridge:client:TriggerEntityAction", function(entityId, actionName, ...)
    local entityData = Entities[entityId]
    -- Check if entity exists locally (it doesn't need to be spawned to queue actions)
    if entityData then
        if actionName == "Stop" then
            ClientEntityActions.StopAction(entityId)
        elseif actionName == "Skip" then
            ClientEntityActions.SkipAction(entityId)
        else
            print(string.format("[ClientEntity] Triggering action '%s' for entity %s", actionName, entityId))
            local currentAction = ClientEntityActions.ActionQueue[entityId] and ClientEntityActions.ActionQueue[entityId][1]
            ClientEntityActions.QueueAction(entityData, actionName, ...)
        end
    -- else
        -- Optional: Log if action received but entity doesn't exist locally at all
        -- print(string.format("[ClientEntity] Received action '%s' for non-existent entity %s.", actionName, entityId))
    end
end)

RegisterNetEvent("community_bridge:client:TriggerEntityActions", function(entityId, actions, endPosition)
    local entityData = Entities[entityId]
    if entityData then
        for _, actionData in pairs(actions) do
            local actionName = actionData.name
            local actionParams = actionData.params
            if actionName == "Stop" then
                ClientEntityActions.StopAction(entityId)
            elseif actionName == "Skip" then
                ClientEntityActions.SkipAction(entityId)
            else
                local currentAction = ClientEntityActions.ActionQueue[entityId] and ClientEntityActions.ActionQueue[entityId][1]
                ClientEntityActions.QueueAction(entityData, actionName, table.unpack(actionParams))
            end
        end
    else
        print(string.format("[ClientEntity] Received actions for non-existent entity %s.", entityId))
    end
end)

-- Resource Stop Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for id, entityData in pairs(Entities) do
            Point.Remove(id) -- Clean up point registration
            RemoveEntity(entityData) -- Clean up spawned game entity
        end
        Entities = {} -- Clear local cache
    end
end)

return ClientEntity
