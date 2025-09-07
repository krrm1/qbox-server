local Entities = {}
local isServer = IsDuplicityVersion()
local registeredFunctions = {}
ReboundEntities = {}

function ReboundEntities.AddFunction(func)
    assert(func, "Func is nil")
    table.insert(registeredFunctions, func)
    return #registeredFunctions
end

function ReboundEntities.RemoveFunction(id)
    assert(id and registeredFunctions[id], "Invalid ID")
    registeredFunctions[id] = false
end

function FireFunctions(...)
    for _, func in pairs(registeredFunctions) do
        func(...)
    end
end

function ReboundEntities.Register(entityData)
    assert(entityData and entityData.position, "Invalid entity data")
    entityData.id = entityData.id or Ids.CreateUniqueId(Entities)
    entityData.isServer = isServer
    setmetatable(entityData, { __tostring = function() return entityData.id end })
    Entities[entityData.id] = entityData
    FireFunctions(entityData)
    return entityData
end

local function Unregister(id)
    Entities[id] = nil
end

function ReboundEntities.GetSyncData(entityData, key)
    return entityData[key]
end

function ReboundEntities.GetAll()
    return Entities
end

function ReboundEntities.GetById(id)
    return Entities[tostring(id)]
end

function ReboundEntities.GetByModel(model)
    local entities = {}
    for _, entity in pairs(Entities) do
        if entity.model == model then
            table.insert(entities, entity)
        end
    end
    return entities
end

function ReboundEntities.GetClosest(pos)
    local closest, closestDist = nil, 9999
    for _, entity in pairs(Entities) do
        local dist = #(pos - entity.position)
        if dist < closestDist then
            closest, closestDist = entity, dist
        end
    end
    return closest
end

function ReboundEntities.GetWithinRadius(pos, radius)
    local entities = {}
    for _, entity in pairs(Entities) do
        if #(pos - entity.position) < radius then
            table.insert(entities, entity)
        end
    end
    return entities
end

function ReboundEntities.SetOnSyncKeyChange(entityData, cb)
    local data = ReboundEntities.GetById(entityData.id or entityData)
    assert(data, "Entity not found")
    data.onSyncKeyChange = cb
end

exports('ReboundEntities', ReboundEntities)

if not isServer then goto client end

function ReboundEntities.Create(entityData, src)
    local entity = ReboundEntities.Register(entityData)
    assert(entity and entity.position, "Invalid entity data")
    entity.rotation = entity.rotation or vector3(0, 0, entityData.heading or 0)
    TriggerClientEvent(GetCurrentResourceName() .. ":client:CreateReboundEntity", src or -1, entity)
    return entity
end


function ReboundEntities.SetCheckRestricted(entityData, cb)
    assert(type(cb) == "function", "Check restricted is not a function")
    entityData.restricted = cb
end


function ReboundEntities.CheckRestricted(src, entityData)
    return entityData.restricted and entityData.restricted(tonumber(src), entityData) or false
end

function ReboundEntities.Refresh(src)
    TriggerClientEvent(GetCurrentResourceName() .. ":client:CreateReboundEntities", tonumber(src), ReboundEntities.GetAccessibleList(src))
end

function ReboundEntities.Delete(id)
    Unregister(id)
    TriggerClientEvent(GetCurrentResourceName() .. ":client:DeleteReboundEntity", -1, id)
end

function ReboundEntities.DeleteMultiple(entityDatas)
    local ids = {}
    for _, data in pairs(entityDatas) do
        Unregister(data.id)
        table.insert(ids, data.id)
    end
    TriggerClientEvent(GetCurrentResourceName() .. ":client:DeleteReboundEntities", -1, ids)
end

function ReboundEntities.CreateMultiple(entityDatas, src, restricted)
    local _entityDatas = {}
    for _, data in pairs(entityDatas) do
        local entity = ReboundEntities.Register(data)
        assert(entity and entity.position, "Invalid entity data")
        entity.rotation = entity.rotation or vector3(0, 0, 0)
        if restricted then ReboundEntities.SetCheckRestricted(entity, restricted) end
        if not ReboundEntities.CheckRestricted(src, entity) then
            _entityDatas[entity.id] = entity
        end
    end
    TriggerClientEvent(GetCurrentResourceName() .. ":client:CreateReboundEntities", src or -1, _entityDatas)
    return _entityDatas
end

function ReboundEntities.SetSyncData(entityData, key, value)
    entityData[key] = value
    if entityData.onSyncKeyChange then
        entityData.onSyncKeyChange(entityData, key, value)
    end
    TriggerClientEvent(GetCurrentResourceName() .. ":client:SetReboundSyncData", -1, entityData.id, key, value)
end

function ReboundEntities.GetAccessibleList(src)
    local list = {}
    for _, data in pairs(ReboundEntities.GetAll()) do
        if not ReboundEntities.CheckRestricted(src, data) then
            list[data.id] = data
        end
    end
    return list
end

RegisterNetEvent("playerJoining", function()
    ReboundEntities.Refresh(source)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Wait(1000)
    for _, src in pairs(GetPlayers()) do
        ReboundEntities.Refresh(src)
    end
end)

::client::
if isServer then return ReboundEntities end

function ReboundEntities.LoadModel(model)
    assert(model, "Model is nil")
    model = type(model) == "number" and model or GetHashKey(model) -- Corrected to GetHashKey
    RequestModel(model)
    for i = 1, 100 do
        if HasModelLoaded(model) then return model end
        Wait(100)
    end
    error(string.format("Failed to load model %s", model))
end

function ReboundEntities.Spawn(entityData)
    local model = entityData.model
    local position = entityData.position
    assert(position, "Position is nil")
    local rotation = entityData.rotation or vector3(0, 0, 0)
    local entity = model and CreateObject(ReboundEntities.LoadModel(model), position.x, position.y, position.z, false, false, false)
    if entity then SetEntityRotation(entity, rotation.x, rotation.y, rotation.z) end
    if entityData.onSpawn then entity = entityData.onSpawn(entityData, entity) or entity end
    return entity, true
end

function ReboundEntities.SetOnSpawn(id, cb)
    local entity = ReboundEntities.GetById(tostring(id))
    assert(entity, "Entity not found")
    entity.onSpawn = cb
    return true
end

function ReboundEntities.Despawn(entityData)
    local entity = entityData.entity
    if entityData.onDespawn then entityData.onDespawn(entityData, entity) end
    if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
    return nil, nil
end

function ReboundEntities.SetOnDespawn(id, cb)
    local entity = ReboundEntities.GetById(tostring(id))
    assert(entity, "Entity not found")
    entity.onDespawn = cb
    return true
end

local spawnLoopRunning = false

function ReboundEntities.SpawnLoop(distanceToCheck, waitTime)
    if spawnLoopRunning then return end
    spawnLoopRunning = true
    distanceToCheck = distanceToCheck or 50
    waitTime = waitTime or 2500
    CreateThread(function()
        while spawnLoopRunning do
            for _, entity in pairs(Entities) do
                local pos = GetEntityCoords(PlayerPedId())
                local position = vector3(entity.position.x, entity.position.y, entity.position.z)
                local dist = #(pos - position)
                if dist <= distanceToCheck and not entity.entity then
                    entity.entity, entity.inRange = ReboundEntities.Spawn(entity)
                elseif dist > distanceToCheck and entity.entity then
                    entity.entity, entity.inRange = ReboundEntities.Despawn(entity)
                end
            end
            Wait(waitTime)
        end
    end)
end

function ReboundEntities.GetByEntity(entity)
    for _, data in pairs(Entities) do
        if data.entity == entity then return data end
    end
end

function ReboundEntities.CreateClient(entityData)
    local entity = ReboundEntities.Register(entityData)
    if entity then ReboundEntities.SpawnLoop() end
    return entity
end

function ReboundEntities.DeleteClient(id)
    local entityData = ReboundEntities.GetById(tostring(id))
    assert(not entityData.isServer, "Cannot delete server entity from client")
    if entityData.entity then ReboundEntities.Despawn(entityData) end
    Unregister(id)
    return true
end

function ReboundEntities.CreateMultipleClient(entityDatas)
    local _entityDatas = {}
    for _, data in pairs(entityDatas) do
        local entityData = ReboundEntities.CreateClient(data)
        _entityDatas[entityData.id] = entityData
    end
    return _entityDatas
end

function ReboundEntities.DeleteMultipleClient(ids)
    for _, id in pairs(ids) do
        ReboundEntities.DeleteClient(id)
    end
end

local function DeleteFromServer(id)
    local entityData = ReboundEntities.GetById(tostring(id))
    if entityData then
        entityData.isServer = nil
        ReboundEntities.DeleteClient(id)
    end
end

local function DeleteMultipleFromServer(ids)
    for _, id in pairs(ids) do
        DeleteFromServer(id)
    end
end

RegisterNetEvent(GetCurrentResourceName() .. ":client:CreateReboundEntity", function(entityData)
    ReboundEntities.CreateClient(entityData)
end)

RegisterNetEvent(GetCurrentResourceName() .. ":client:DeleteReboundEntity", function(id)
    DeleteFromServer(id)
end)

RegisterNetEvent(GetCurrentResourceName() .. ":client:CreateReboundEntities", function(entityDatas)
    ReboundEntities.CreateMultipleClient(entityDatas)
end)

RegisterNetEvent(GetCurrentResourceName() .. ":client:DeleteReboundEntities", function(ids)
    ReboundEntities.DeleteMultipleClient(ids)
end)

RegisterNetEvent(GetCurrentResourceName() .. ":client:SetReboundSyncData", function(id, key, value)
    local entityData = ReboundEntities.GetById(id)
    if not entityData then return end
    entityData[key] = value
    if entityData.onSyncKeyChange then
        entityData.onSyncKeyChange(entityData, key, value)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    spawnLoopRunning = false
    for _, entity in pairs(Entities) do
        if entity.entity then DeleteEntity(tonumber(entity.entity)) end
    end
end)

return ReboundEntities
