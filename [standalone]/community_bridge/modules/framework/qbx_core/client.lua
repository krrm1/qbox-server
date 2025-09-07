---@diagnostic disable: duplicate-set-field
if GetResourceState('qbx_core') ~= 'started' then return end

QBox = exports.qbx_core

Framework = Framework or {}

---This will get the name of the framework being used (if a supported framework).
---@return string
Framework.GetFrameworkName = function()
    return 'qbx_core'
end

---This will return true if the player is loaded, false otherwise.
---This could be useful in scripts that rely on player loaded events and offer a debug mode to hit this function.
---@return boolean
Framework.GetIsPlayerLoaded = function()
    return LocalPlayer.state.isLoggedIn or false
end

---This will return a table of the player data, this will be in the framework format.
---This is mainly for internal bridge use and should be avoided.
---@return table
Framework.GetPlayerData = function()
    return QBox.GetPlayerData()
end

---This will return a table of all the jobs in the framework.
---@return table
Framework.GetFrameworkJobs = function()
    return QBox.GetJobs()
end

---This will get the players birth date
---@return string
Framework.GetPlayerDob = function()
    local playerData = Framework.GetPlayerData()
    return playerData.charinfo.birthdate
end

---Will Display the help text message on the screen
---@param message string
---@param position string
---@return nil
Framework.ShowHelpText = function(message, position)
    return exports.ox_lib:showTextUI(message, { position = position or 'top-center' })
end

---This will hide the help text message on the screen
---@return nil
Framework.HideHelpText = function()
    return exports.ox_lib:hideTextUI()
end

---This will return the players metadata for the specified metadata key.
---@param metadata table | string
---@return table | string | number | boolean
Framework.GetPlayerMetaData = function(metadata)
    local playerData = Framework.GetPlayerData()
    return playerData.metadata[metadata]
end

---This will send a notification to the player.
---@param message string
---@param type string
---@param time number
---@return nil
Framework.Notify = function(message, type, time)
    return QBox:Notify("Notification", type, time, message)
end

---This will get the players identifier (citizenid) etc.
---@return string
Framework.GetPlayerIdentifier = function()
    return Framework.GetPlayerData().citizenid
end

---This will get the players name (first and last).
---@return string
---@return string
Framework.GetPlayerName = function()
    local playerData = Framework.GetPlayerData()
    return playerData.charinfo.firstname, playerData.charinfo.lastname
end

---Depricated : This will return the players job name, job label, job grade label and job grade level
---@return string
---@return string
---@return string
---@return string
Framework.GetPlayerJob = function()
    local playerData = Framework.GetPlayerData()
    return playerData.job.name, playerData.job.label, playerData.job.grade.name, playerData.job.grade.level
end

---This will return the players job name, job label, job grade label job grade level, boss status, and duty status in a table
---@return table
Framework.GetPlayerJobData = function()
    local playerData = Framework.GetPlayerData()
    local jobData = playerData.job
    return {
        jobName = jobData.name,
        jobLabel = jobData.label,
        gradeName = jobData.grade.name,
        gradeLabel = jobData.grade.name,
        gradeRank = jobData.grade.level,
        boss = jobData.isboss,
        onDuty = jobData.onduty,
    }
end

---This will return the players inventory as a table in the ox_inventory style flormat.
---@return table
Framework.GetPlayerInventory = function()
    return Framework.GetPlayerData().items
end

---This will return the players money by type, I recommend not useing this as its the client and not secure or to be trusted.
---Use case is for a ui or a menu I guess.
---@param _type string
---@return number
Framework.GetAccountBalance = function(_type)
    local player = Framework.GetPlayerData()
    if not player then return 0 end
    local account = player.money
    if _type == 'money' then _type = 'cash' end
    return account[_type] or 0
end

---This will return the vehicle properties for the specified vehicle.
---@param vehicle number
---@return table
Framework.GetVehicleProperties = function(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return {} end
    local vehicleProps = lib.getVehicleProperties(vehicle)
    return vehicleProps or {}
end

---This will set the vehicle properties for the specified vehicle.
---@param vehicle number
---@param properties table
---@return boolean
Framework.SetVehicleProperties = function(vehicle, properties)
    if not vehicle or not DoesEntityExist(vehicle) then return false end
    if not properties then return false end
    if NetworkGetEntityIsNetworked(vehicle) then
        local vehNetID = NetworkGetNetworkIdFromEntity(vehicle)
        local entOwner = GetPlayerServerId(NetworkGetEntityOwner(vehNetID))
        if entOwner ~= GetPlayerServerId(PlayerId()) then
            NetworkRequestControlOfEntity(vehicle)
            local count = 0
            while not NetworkHasControlOfEntity(vehicle) and count < 3000 do
                Wait(1)
                count = count + 1
            end
        end
    end
    return true, lib.setVehicleProperties(vehicle, properties)
end

---This will return the item count for the specified item in the players inventory.
---@param item string
---@return number
Framework.GetItemCount = function(item)
    -- This seems to be exclusively for ox_inventory, if other inventories are used, they need to be bridged in the inventory module. Until then we will return 0 and a print.
    return 0, print("Community_bridge:WARN: GetItemCount is not implemented for this framework, please use the inventory module to get the item count. If you are using a diffrent inventory please let us know so we can bridge it and have less nonsense.")
end

---This will get a players dead status.
---@return boolean
Framework.GetIsPlayerDead = function()
    local platerData = Framework.GetPlayerData()
    return platerData.metadata["isdead"] or platerData.metadata["inlaststand"]
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1500)
    TriggerEvent('community_bridge:Client:OnPlayerLoaded')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent('community_bridge:Client:OnPlayerUnload')
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(data)
    TriggerEvent('community_bridge:Client:OnPlayerJobUpdate', data.name, data.label, data.grade.name, data.grade.level)
end)

return Framework