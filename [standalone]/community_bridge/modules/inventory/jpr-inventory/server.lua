---@diagnostic disable: duplicate-set-field
if GetResourceState('jpr-inventory') ~= 'started' then return end

local jpr = exports['jpr-inventory']
local registeredShops = {}

Inventory = Inventory or {}
Inventory.Stashes = Inventory.Stashes or {}

---This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number
---@param metadata table
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = count, slot = slot, metadata = metadata})
    return exports['jpr-inventory']:AddItem(src, item, count, slot, metadata, 'community_bridge Item added')
end

---This will remove an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number
---@param metadata table
---@return boolean
Inventory.RemoveItem = function(src, item, count, slot, metadata)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "remove", item = item, count = count, slot = slot, metadata = metadata})
    return exports['jpr-inventory']:RemoveItem(src, item, count, slot, 'community_bridge Item removed')
end

---This will return a table with the item info, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemTable = Framework.GetItemInfo(item)
    itemTable.image = Inventory.GetImagePath(item)
    return itemTable
end

---This will return the entire items table from the inventory.
---@return table 
Inventory.Items = function()
    return Framework.Shared.Items
end

---Returns the specified slot data as a table.
---format {weight, name, metadata, slot, label, count}
---@param src number
---@param slot number
---@return table
Inventory.GetItemBySlot = function(src, slot)
    local slotData = jpr:GetItemBySlot(src, slot)
    if not slotData then return {} end
    return {
        name = slotData.name,
        label = slotData.label,
        weight = slotData.weight,
        slot = slot,
        count = slotData.amount,
        metadata = slotData.info,
        stack = slotData.unique,
        description = slotData.description
    }
end

---This will open the specified stash for the src passed.
---@param src number
---@param _type string
---@param id number||string
---@return nil
Inventory.OpenStash = function(src, _type, id)
    _type = _type or "stash"
    local tbl = Inventory.Stashes[id]
    TriggerClientEvent('community_bridge:client:jpr-inventory:openStash', src, id, { weight = tbl.weight, slots = tbl.slots })
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
    Inventory.Stashes[id] = {
        id = id,
        label = label,
        slots = slots,
        weight = weight,
        owner = owner,
        groups = groups,
        coords = coords
    }
    return true, id
end

---This will add items to a trunk, and return true or false based on success
---If a trunk with the identifier does not exist, it will create one with default values.
---@param identifier string
---@param items table
---@return boolean
Inventory.AddTrunkItems = function(identifier, items)
    if type(items) ~= "table" then return false end
    return false, print("AddItemsToTrunk is not implemented in jpr-inventory, because of this we dont have a way to add items to a trunk.")
end

---This will clear the specified inventory, will always return true unless a value isnt passed correctly.
---@param id string
---@return boolean
Inventory.ClearStash = function(id, _type)
    if type(id) ~= "string" then return false end
    if Inventory.Stashes[id] then Inventory.Stashes[id] = nil end
    return false, print("ClearInventory is not implemented in jpr-inventory, because of this we dont have a way to clear a stash.")
end

---This will return a boolean if the player has the item.
---@param src number
---@param item string
---@return boolean
Inventory.HasItem = function(src, item)
    return jpr:HasItem(src, item, 1)
end

---This is to get if there is available space in the inventory, will return boolean.
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    return true
end

---This will update the plate to the vehicle inside the inventory. (It will also update with jg-mechanic if using it)
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    local queries = {
        'UPDATE gloveboxitems SET plate = @newplate WHERE plate = @oldplate',
        'UPDATE trunkitems SET plate = @newplate WHERE plate = @oldplate',
    }
    local values = { newplate = newplate, oldplate = oldplate }
    MySQL.transaction.await(queries, values)
    if GetResourceState('jg-mechanic') ~= 'started' then return true end
    return true, exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
end

---This will get the image path for an item, it is an alternate option to GetItemInfo. If a image isnt found will revert to community_bridge logo (useful for menus)
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("jpr-inventory", string.format("html/images/%s.png", item))
    local imagePath = file and string.format("nui://jpr-inventory/html/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---This will open the specified shop for the src passed.
---@param src number
---@param shopTitle string
Inventory.OpenShop = function(src, shopTitle)
    jpr:OpenShop(src, shopTitle)
end

---This will register a shop, if it already exists it will return true.
---@param shopTitle string
---@param shopInventory table
---@param shopCoords table
---@param shopGroups table
Inventory.RegisterShop = function(shopTitle, shopInventory, shopCoords, shopGroups)
    if not shopTitle or not shopInventory or not shopCoords then return end
    if registeredShops[shopTitle] then return true end

    local repackItems = {}
    local repackedShopItems = {name = shopTitle, label = shopTitle, coords = shopCoords, items = repackItems, slots = #shopInventory, }
    for k, v in pairs(shopInventory) do
        table.insert(repackItems, { name = v.name, price = v.price or 1000, amount = v.count or 1, slot = k })
    end

    jpr:CreateShop(repackedShopItems)
    registeredShops[shopTitle] = true
    return true
end

return Inventory