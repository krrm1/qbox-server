---@diagnostic disable: duplicate-set-field
if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports["es_extended"]:getSharedObject()
Callback = Callback or Require("lib/utility/shared/callbacks.lua")

Framework = Framework or {}

local cachedItemList = nil
-- This is an internal function, its here to attempt to emulate qbs shared items mainly.
Framework.ItemList = function()
    if cachedItemList then return cachedItemList end
    local items = Callback.Trigger('community_bridge:Callback:GetFrameworkItems', false)
    cachedItemList = { Items = items.Items or {} }
    return cachedItemList
end

---This will get the name of the framework being used (if a supported framework).
---@return string
Framework.GetFrameworkName = function()
    return 'es_extended'
end

---This will return true if the player is loaded, false otherwise.
---This could be useful in scripts that rely on player loaded events and offer a debug mode to hit this function.
---@return boolean
Framework.GetIsPlayerLoaded = function()
    return ESX.IsPlayerLoaded()
end

---This will return a table of the player data, this will be in the framework format.
---This is mainly for internal bridge use and should be avoided.
---@return table
Framework.GetPlayerData = function()
    return ESX.GetPlayerData()
end

---This will return a table of all the jobs in the framework.
---@return table
Framework.GetFrameworkJobs = function()
    local jobs = Callback.Trigger('community_bridge:Callback:GetFrameworkJobs', false)
    return jobs
end

---This will return the players birth date
---@return string
Framework.GetPlayerDob = function()
    local playerData = Framework.GetPlayerData()
    local dob = playerData.dateofbirth
    return dob
end

---This will return the players metadata for the specified metadata key.
---@param metadata table | string
---@return table | string | number | boolean
Framework.GetPlayerMetaData = function(metadata)
    return Framework.GetPlayerData().metadata[metadata]
end

---This will send a notification to the player.
---@param message string
---@param type string
---@param time number
---@return nil
Framework.Notify = function(message, type, time)
    return ESX.ShowNotification(message, type, time)
end

---Will Display the help text message on the screen
---@param message string
---@param _ unknown
---@return nil
Framework.ShowHelpText = function(message, _)
    return exports['esx_textui']:TextUI(message, "info")
end

---This will hide the help text message on the screen
---@return nil
Framework.HideHelpText = function()
    return exports['esx_textui']:HideUI()
end

---This will get the players identifier (citizenid) etc.
---@return string
Framework.GetPlayerIdentifier = function()
    local playerData = Framework.GetPlayerData()
    return playerData.identifier
end

---This will get the players name (first and last).
---@return string
---@return string
Framework.GetPlayerName = function()
    local playerData = Framework.GetPlayerData()
    return playerData.firstName, playerData.lastName
end

---Depricated : This will return the players job name, job label, job grade label and job grade level
---@return string
---@return string
---@return string
---@return string
Framework.GetPlayerJob = function()
    local playerData = Framework.GetPlayerData()
    return playerData.job.name, playerData.job.label, playerData.job.grade_label, playerData.job.grade
end

---This will return the players job name, job label, job grade label job grade level, boss status, and duty status in a table
---@return table
Framework.GetPlayerJobData = function()
    local playerData = Framework.GetPlayerData()
    local jobData = playerData.job
    local isBoss = (jobData.grade_name == "boss")
    return {
        jobName = jobData.name,
        jobLabel = jobData.label,
        gradeName = jobData.grade_name,
        gradeLabel = jobData.grade_label,
        gradeRank = jobData.grade,
        boss = isBoss,
        onDuty = jobData.onduty,
    }
end

---This will return if the player has the specified item in their inventory.
---@param item string
---@return boolean
Framework.HasItem = function(item)
	local hasItem = ESX.SearchInventory(item, true)
	return hasItem > 0 and true or false
end

---This will return the item count for the specified item in the players inventory.
---@param item string
---@return number
Framework.GetItemCount = function(item)
    local inventory = Framework.GetPlayerInventory()
    if not inventory then return 0 end
    return inventory[item].count or 0
end

---This will return a table of the players inventory
---@return table
Framework.GetPlayerInventory = function()
    local playerData = Framework.GetPlayerData()
    return playerData.inventory
end

---This will return the players money by type, I recommend not useing this as its the client and not secure or to be trusted.
---Use case is for a ui or a menu I guess.
---@param _type string
---@return number
Framework.GetAccountBalance = function(_type)
    local player = Framework.GetPlayerData()
    if not player then return 0 end
    local accounts = player.accounts
    if _type == 'cash' then _type = 'money' end
    for _, account in ipairs(accounts) do
        if account.name == _type then
            return account.money or 0
        end
    end
    return 0
end

---This will return the vehicle properties for the specified vehicle.
---@param vehicle number
---@return table
Framework.GetVehicleProperties = function(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return {} end
    local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
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
    -- Every framework version does this just a diffrent key I guess?
    if properties.color1 and type(properties.color1) == 'table' then
        properties.customPrimaryColor = {properties.color1[1], properties.color1[2], properties.color1[3]}
        properties.color1 = nil
    end
    if properties.color2 and type(properties.color2) == 'table' then
        properties.customSecondaryColor = {properties.color2[1], properties.color2[2], properties.color2[3]}
        properties.color2 = nil
    end
    return true, ESX.Game.SetVehicleProperties(vehicle, properties)
end

---This will get a players dead status.
---@return boolean
Framework.GetIsPlayerDead = function()
    local playerData = Framework.GetPlayerData()
    return playerData.dead
end

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    Wait(1500)
    TriggerEvent('community_bridge:Client:OnPlayerLoaded')
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    TriggerEvent('community_bridge:Client:OnPlayerUnload')
end)

RegisterNetEvent('esx:setJob', function(data)
    TriggerEvent('community_bridge:Client:OnPlayerJobUpdate', data.name, data.label, data.grade_label, data.grade)
end)

return Framework