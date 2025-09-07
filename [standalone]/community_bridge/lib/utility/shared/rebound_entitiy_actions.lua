local ReboundEntities = ReboundEntities or Require("lib/utility/shared/rebound_entities.lua") -- Fixed path
local Action = Action or Require("lib/entities/shared/actions.lua") -- Fixed path and name
local LA = LA or Require("lib/utility/shared/la.lua") -- Fixed path

REA = {}

if not IsDuplicityVersion() then goto client end



if IsDuplicityVersion() then return end
::client::

local ActionsInProgress = {}


Action.Create("LerpToPosition", function(reboundId, start, position, duration, shouldRepeat, overrideStartTime)
    local re = ReboundEntities.GetById(reboundId) -- Use GetById
    assert(re, "Rebound entity not found")
    local entity = re and re.entity
    if not entity or not DoesEntityExist(entity) then return end -- Check existence
    local startTime = GetGameTimer()
    local endTime = overrideStartTime or startTime + duration
    ActionsInProgress[reboundId] = {reboundId, start, position, duration, shouldRepeat, startTime}
    local t = 0
    CreateThread(function()
        while shouldRepeat or t < 1 do
            -- Check if entity still exists
            if not re.entity or not DoesEntityExist(re.entity) then
                ActionsInProgress[reboundId] = nil
                break
            end
            entity = re.entity -- Update entity handle in case it changed (unlikely but safe)
            t = (GetGameTimer() - startTime) / duration
            local lerpPosition = LA.LerpVector(start, position, t)
            SetEntityCoordsNoOffset(entity, lerpPosition.x, lerpPosition.y, lerpPosition.z, false, false, false) -- Use NoOffset
            Wait(0)
        end
        -- Set final position if not repeating
        if not shouldRepeat and re.entity and DoesEntityExist(re.entity) then
             SetEntityCoordsNoOffset(re.entity, position.x, position.y, position.z, false, false, false)
        end
        ActionsInProgress[reboundId] = nil -- Clear when done
    end)
end)
