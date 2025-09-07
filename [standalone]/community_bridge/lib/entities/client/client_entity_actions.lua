

ClientEntityActions = {}
ClientEntityActions.ActionThreads = {} -- Store running action threads { [entityId] = thread }
ClientEntityActions.ActionQueue = {} -- Stores pending actions { [entityId] = {{name="ActionName", args={...}}, ...} }
ClientEntityActions.IsActionRunning  = {} -- Tracks if an action is currently running { [entityId] = boolean }
ClientEntityActions.RegisteredActions  = {} -- New: Registry for action implementations { [actionName] = function(entityData, ...) }
-- Forward declaration


--- Processes the next action in the queue for a given entity.
-- @param entityId string|number The ID of the entity.
function ClientEntityActions.ProcessNextAction(entityId)
    if ClientEntityActions.IsActionRunning [entityId] then return end -- Already running something
    local queue = ClientEntityActions.ActionQueue[entityId]
    if not queue or #queue == 0 then return end -- Queue is empty

    local nextAction = table.remove(queue, 1) -- Dequeue (FIFO)
    local entityData = ClientEntity.Get(entityId) -- Assumes ClientEntity is accessible
    -- Check if entity is still valid and spawned before starting next action
    if not entityData or not entityData.spawned or not DoesEntityExist(entityData.spawned) then
        -- Entity despawned while idle, clear queue and do nothing
        ClientEntityActions.ActionQueue[entityId] = nil
        return
    end

    -- Look up the action in the registry
    local actionFunc = ClientEntityActions.RegisteredActions [nextAction.name]
    if actionFunc then
        -- print(string.format("[ClientEntityActions] Starting action '%s' for entity %s", nextAction.name, entityId))
        ClientEntityActions.IsActionRunning [entityId] = true
        -- Call the registered function
        ClientEntityActions.ActionQueue[entityId] = actionFunc(entityData, table.unpack(nextAction.args))
        if not ClientEntityActions.ActionQueue[entityId] then
            -- If the action function doesn't return a queue, set it to nil
            ClientEntityActions.IsActionRunning[entityId] = false
            ClientEntityActions.ProcessNextAction(entityId) -- Try next action if this one failed immediately
        end
    else
        print(string.format("[ClientEntityActions] Unknown action '%s' dequeued for entity %s", nextAction.name, entityId))
        -- Skip unknown action and try the next one immediately
        ClientEntityActions.ActionQueue[entityId]  = ClientEntityActions.ProcessNextAction(entityId)
    end
end
--- Registers a custom action implementation.
-- The action function should handle its own logic, including threading if needed,
-- and MUST call ClientEntityActions.ProcessNextAction(entityData.id) when it completes or fails,
-- after setting ClientEntityActions.IsActionRunning [entityData.id] = false.
-- @param actionName string The name used to trigger this action.
-- @param actionFunc function The function to execute. Signature: function(entityData, ...)
function ClientEntityActions.RegisterAction(actionName, actionFunc)
    if ClientEntityActions.RegisteredActions [actionName] then
        print(string.format("[ClientEntityActions] WARNING: Overwriting registered action '%s'", actionName))
    end
    assert(type(actionName) == "string", "actionName must be a string")
    ClientEntityActions.RegisteredActions[actionName] = actionFunc
    -- print(string.format("[ClientEntityActions] Registered action: %s", actionName))
end

--- Queues an action for an entity. Starts processing if idle.
-- @param entityData table The entity data.
-- @param actionName string The name of the action.
-- @param ... any Arguments for the action.
function ClientEntityActions.QueueAction(entityData, actionName, ...)
    local entityId = entityData.id
    if not ClientEntityActions.ActionQueue[entityId] then
        ClientEntityActions.ActionQueue[entityId] = {}
    end

    local actionArgs = {...}
    table.insert(ClientEntityActions.ActionQueue[entityId], { name = actionName, args = actionArgs })
    -- print(string.format("[ClientEntityActions] Queued action '%s' for entity %s. Queue size: %d", actionName, entityId, #ClientEntityActions.ActionQueue[entityId]))

    -- If the entity isn't currently doing anything, start processing immediately
    if not ClientEntityActions.IsActionRunning [entityId] then
        ClientEntityActions.ProcessNextAction(entityId)
    end
end
--- Stops the current action and clears the queue for a specific entity.
-- @param entityId string|number The ID of the entity.
function ClientEntityActions.StopAction(entityId)
    -- print(string.format("[ClientEntityActions] Stopping all actions for entity %s", entityId))
    ClientEntityActions.ActionQueue[entityId] = nil -- Clear the queue
    ClientEntityActions.IsActionRunning [entityId] = false -- Mark as not running (this will stop loops in threads)

    -- Stop current task/thread if applicable
    if ClientEntityActions.ActionThreads[entityId] then
        -- Lua threads stop themselves based on ClientEntityActions.IsActionRunning  flag
        ClientEntityActions.ActionThreads[entityId] = nil
    end

    -- Specific task clearing for peds
    local entityData = ClientEntity.Get(entityId)
    if entityData and entityData.spawned and DoesEntityExist(entityData.spawned) then
        if IsEntityAPed(entityData.spawned) then
            ClearPedTasksImmediately(entityData.spawned) -- Use Immediately for forceful stop
        end
        -- Other entity types might need different stop logic
    end
end
--- Skips the current action and starts the next one in the queue, if any.
-- @param entityId string|number The ID of the entity.
function ClientEntityActions.SkipAction(entityId)
    if not ClientEntityActions.IsActionRunning [entityId] then
        -- print(string.format("[ClientEntityActions] SkipAction called for %s, but no action running.", entityId))
        return -- Nothing to skip
    end
    -- print(string.format("[ClientEntityActions] Skipping current action for entity %s", entityId))

    ClientEntityActions.IsActionRunning [entityId] = false -- Mark as not running (this will stop loops in threads)

    -- Stop current task/thread if applicable
    if ClientEntityActions.ActionThreads[entityId] then
        ClientEntityActions.ActionThreads[entityId] = nil
    end

    local entityData = ClientEntity.Get(entityId)
    if entityData and entityData.spawned and DoesEntityExist(entityData.spawned) then
        if IsEntityAPed(entityData.spawned) then
            ClearPedTasksImmediately(entityData.spawned)
        end
    end

    -- Immediately try to process the next action
    ClientEntityActions.ProcessNextAction(entityId)
end
-- Add server-callable functions for Stop and Skip
function ClientEntityActions.Stop(entityData)
    ClientEntityActions.StopAction(entityData.id)
end

function ClientEntityActions.Skip(entityData)
    ClientEntityActions.SkipAction(entityData.id)
end

return ClientEntityActions
