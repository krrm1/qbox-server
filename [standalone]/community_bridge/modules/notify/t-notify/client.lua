---@diagnostic disable: duplicate-set-field
Notify = Notify or {}
local resourceName = "t-notify"
local configValue = BridgeSharedConfig.Notify
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

Notify.GetResourceName = function()
    return resourceName
end

---This will send a notify message of the type and time passed
---@param message string
---@param _type string
---@param time number
---@return nil
Notify.SendNotify = function(message, _type, time)
    time = time or 3000
    _type = _type or "info"
    return exports['t-notify']:Alert({ style = _type, message = message, duration = time, })
end

return Notify