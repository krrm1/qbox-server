---@diagnostic disable: duplicate-set-field
if GetResourceState('core_inventory') ~= 'started' then return end

Inventory = Inventory or {}
Inventory.Stashes = Inventory.Stashes or {}
Callback = Callback or Require("lib/utility/shared/callbacks.lua")
local core = exports.core_inventory

---This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number
---@param metadata table
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = count, slot = slot, metadata = metadata})
    return core:addItem(src, item, count, metadata)
end

---This will remove an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number
---@param metadata table
---@return boolean
Inventory.RemoveItem = function(src, item, count, slot, metadata)
    if not slot and metadata then
        local inv = Inventory.GetPlayerInventory(src)
        if not inv then return false end
        for _, v in pairs(inv) do
            if v.name == item and v.metadata == metadata then
                slot = v.slot
                break
            end
        end
    end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "remove", item = item, count = count, slot = slot, metadata = metadata})
    if slot then
        local identifier = Framework.GetPlayerIdentifier(src)
        if not identifier then return false end
        local framework = Bridge.Framework.GetFrameworkName()
        if framework == 'es_extended' then
            identifier = string.gsub(identifier, ":", "")
        end
        local weirdInventoryName = 'content-' .. identifier
        return core:removeItemExact(weirdInventoryName, slot, count)
    end
    core:removeItem(src, item, count)
    return true
    -- I hate this inventory so much, I am so sorry for this.
end

---This will return the count of the item in the players inventory, if not found will return 0.
---if metadata is passed it will find the matching items count.
---@param src number
---@param item string
---@param metadata table
---@return number
Inventory.GetItemCount = function(src, item, metadata)
    if metadata then
        local inv = Inventory.GetPlayerInventory(src)
        local deepCount = 0
        if not inv then return 0 end
        for _, v in pairs(inv) do
            if v.name == item and v.metadata == metadata then
                deepCount = deepCount + v.count
            end
        end
        return deepCount
    end
    local count = core:getItemCount(src, item)
    return count or 0
end

---This wil return the players inventory.
---@param src number
---@return table
Inventory.GetPlayerInventory = function(src)
    local frameworkInUse = Bridge.Framework.GetFrameworkName()
    if frameworkInUse == 'qb-core' then
        return Bridge.Framework.GetPlayerInventory(src)
    end
    local playerItems = core:getInventory(src)
    local repackedTable = {}
    for _, v in pairs(playerItems) do
        if v.metadata and v.count > 1 then
            local plaseFixThisExportCuzThisIsPainful = core:getItems(src, v.name)
            if plaseFixThisExportCuzThisIsPainful then
                for _, item in pairs(plaseFixThisExportCuzThisIsPainful) do
                    table.insert(repackedTable, {
                        name = v.name,
                        count = item.count,
                        metadata = item.metadata,
                        slot = item.id,
                    })
                end
            end
        else
            table.insert(repackedTable, {
                name = v.name,
                count = v.count,
                metadata = v.metadata,
                slot = v.id,
            })
        end
    end
    return repackedTable
end

---Returns the specified slot data as a table.
---format {weight, name, metadata, slot, label, count}
---@param src number
---@param slot number
---@return table
Inventory.GetItemBySlot = function(src, slot)
    local inv = Inventory.GetPlayerInventory(src)
    if not inv then return {} end
    for _, v in pairs(inv) do
        if v.slot == slot then
            return {
                name = v.name,
                count = v.count,
                metadata = v.metadata,
                slot = v.slot,
            }
        end
    end
    return {}
end

---This will set the metadata of an item in the inventory.
---@param src number
---@param item string
---@param slot number
---@param metadata table
---@return nil
Inventory.SetMetadata = function(src, item, slot, metadata)
    core:setMetadata(src, slot, metadata)
end

---This will open the specified stash for the src passed.
---@param src number
---@param _type string
---@param id number||string
---@return nil
Inventory.OpenStash = function(src, _type, id)
    _type = _type or "stash"
    local tbl = Inventory.Stashes[id]
    core:openInventory(src, id, _type, tbl.slots, tbl.weight, true, nil, false)
end

---This will register a stash
---@param id number|string
---@param label string
---@param slots number
---@param weight number
---@param owner string
---@param groups table
---@param coords table
---@return boolean
---@return string|number
Inventory.RegisterStash = function(id, label, slots, weight, owner, groups, coords)
    if Inventory.Stashes[id] then return true, id end
    if not slots then slots = 30 end
    local mathyShit = slots / 2
    Inventory.Stashes[id] = {
        id = id,
        label = label,
        slots = mathyShit,
        weight = mathyShit,
        owner = owner,
        groups = groups,
        coords = coords
    }
    return true, id
end

---This will return a boolean if the player has the item.
---@param src number
---@param item string
---@return boolean
Inventory.HasItem = function(src, item)
    return core:getItemCount(src, item) > 0
end

---This is to get if there is available space in the inventory, will return boolean.
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    return true
end

---This will add items to a trunk, and return true or false based on success
---If a trunk with the identifier does not exist, it will create one with default values.
---@param identifier string
---@param items table
---@return boolean
Inventory.AddTrunkItems = function(identifier, items)
    if type(items) ~= "table" then return false end
    return false, print("AddItemsToTrunk is not implemented in core_inventory, because of this we dont have a way to add items to a trunk.")
end

---This will clear the specified inventory, will always return true unless a value isnt passed correctly.
---@param id string
---@return boolean
Inventory.ClearStash = function(id, _type)
    if type(id) ~= "string" then return false end
    if Inventory.Stashes[id] then Inventory.Stashes[id] = nil end
    return false, print("ClearInventory is not implemented in core_inventory, because of this we dont have a way to clear a stash.")
end

---This will update the plate to the vehicle inside the inventory. (It will also update with jg-mechanic if using it)
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    -- have no clue if this will work but fingers crossed
    local queries = {
        'UPDATE coreinventories SET name = @newplate WHERE name = @oldplate',
        'UPDATE coreinventories SET name = @newplate WHERE name = @glovebox_oldplate',
        'UPDATE coreinventories SET name = @newplate WHERE name = @trunk_oldplate',
    }
    local values = {
        newplate = newplate,
        oldplate = oldplate,
        glovebox_oldplate = 'glovebox-' .. oldplate,
        trunk_oldplate = 'trunk-' .. oldplate
    }
    MySQL.transaction.await(queries, values)
    if GetResourceState('jg-mechanic') ~= 'started' then return true end
    return true, exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
end

---This will get the image path for an item, it is an alternate option to GetItemInfo. If a image isnt found will revert to community_bridge logo (useful for menus)
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("core_inventory", string.format("html/img/%s.png", item))
    local imagePath = file and string.format("nui://core_inventory/html/img/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---This is used for the esx users, documentation doesnt show a client side available option for the inventory so we use jank callbacks to get this.
Callback.Register('community_bridge:Callback:core_inventory', function(source)
    local items = core:getItemsList()
	return items or {}
end)

---This will return the entire items table from the inventory.
---@return table 
Inventory.Items = function()
    return core:getItemsList()
end

return Inventory