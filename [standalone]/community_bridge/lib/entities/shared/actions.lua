local Actions = {}
Action = {}


if not IsDuplicityVersion() then goto client end

function Action.Fire(id, players, ...)
    local action = Actions[id]
    if not action then return end
    if type(players) == "table" then
        for _, player in ipairs(players) do
            TriggerClientEvent(GetCurrentResourceName() .. "client:Action", tonumber(player), id, ...)
        end
        return
    end
    TriggerClientEvent(GetCurrentResourceName() .. "client:Action", tonumber(players or -1), id, ...)
end

if IsDuplicityVersion() then return Actions end
::client::

function Action.Create(id, action)
    assert(type(id) == "string", "id must be a string")
    assert(type(action) == "function", "action must be a function")
    Actions[id] = action
end

function Action.Remove(id)
    Actions[id] = nil
end

function Action.Get(id)
    return Actions[id]
end

function Action.GetAll()
    return Actions
end

RegisterNetEvent(GetCurrentResourceName() .. "client:Action", function(id, ...)
    local action = Actions[id]
    if not action then return end
    action(...)
end)

exports("Action", Action)
return Action


