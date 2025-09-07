---@diagnostic disable: duplicate-set-field
if GetResourceState('tgiann-inventory') ~= 'started' then return end

local tgiann = exports["tgiann-inventory"]

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
    return tgiann:AddItem(src, item, count, slot, metadata, false)
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
    return tgiann:RemoveItem(src, item, count, slot, metadata)
end

---This will return a table with the item info, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemData = tgiann:GetItemList()
    if not itemData[item] then return {} end
    return {
        name = itemData.name or "Missing Name",
        label = itemData.label or "Missing Label",
        stack = itemData.unique or "false",
        weight = itemData.weight or "0",
        description = itemData.description or "none",
        image = itemData.image or Inventory.GetImagePath(item),
    }
end

---This will return the entire items table from the inventory.
---@return table 
Inventory.Items = function()
    return tgiann:GetItemList()
end

---This will return the count of the item in the players inventory, if not found will return 0.
---
---if metadata is passed it will find the matching items count.
---@param src number
---@param item string
---@param metadata table
---@return number
Inventory.GetItemCount = function(src, item, metadata)
    local _item = tgiann:GetItemByName(src, item, metadata)
    return _item.amount or 0
end

---This wil return the players inventory.
---@param src number
---@return table
Inventory.GetPlayerInventory = function(src)
    local inventory = tgiann:GetPlayerItems(src)
    local items = {}
    for _, v in pairs(inventory) do
        if tonumber(_) then
            table.insert(items, {name = v.name, label = v.name, weight = 0, description = v.description, slot = v.slot, count = v.amount, metadata = v.info})
        end
    end
    return items
end

---Returns the specified slot data as a table.
---
---format {weight, name, metadata, slot, label, count}
---@param src number
---@param slot number
---@return table
Inventory.GetItemBySlot = function(src, slot)
    local item = tgiann:GetItemBySlot(src, slot)
    if not item then return {} end
    return {
        name = item.name,
        label = item.label,
        weight = item.weight,
        slot = slot,
        count = item.amount,
        metadata = item.info,
        stack = item.unique or false,
        description = item.description
    }
end

---This will set the metadata of an item in the inventory.
---@param src number
---@param item string
---@param slot number
---@param metadata table
---@return nil
Inventory.SetMetadata = function(src, item, slot, metadata)
    tgiann:UpdateItemMetadata(src, item, slot, metadata)
end

---This will open the specified stash for the src passed.
---@param src number
---@param _type string
---@param id number||string
---@return nil
Inventory.OpenStash = function(src, _type, id)
    _type = _type or "stash"
    local tbl = Inventory.Stashes[id]
    return tgiann:ForceOpenInventory(src, _type, id, tbl and { maxWeight = tbl.weight , slots = tbl.slot, label = tbl.label})
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

---This will return a boolean if the player has the item.
---@param src number
---@param item string
---@return boolean
Inventory.HasItem = function(src, item)
    return tgiann:HasItem(src, item, 1)
end

---This is to get if there is available space in the inventory, will return boolean.
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    return tgiann:CanCarryItem(src, item, count)
end

---This will update the plate to the vehicle inside the inventory. (It will also update with jg-mechanic if using it)
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    local queries = {
        'UPDATE tgiann_inventory_trunkitems SET plate = @newplate WHERE plate = @oldplate',
        'UPDATE tgiann_inventory_gloveboxitems SET plate = @newplate WHERE plate = @oldplate',
    }
    local values = { newplate = newplate, oldplate = oldplate }
    MySQL.transaction.await(queries, values)
    tgiann:UpdateVehicle(oldplate, newplate)
    if GetResourceState('jg-mechanic') ~= 'started' then return true end
    return true, exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
end

---This will add items to a trunk, and return true or false based on success
---@param identifier string
---@param items table
---@return boolean
Inventory.AddTrunkItems = function(identifier, items)
    local id = "trunk"..identifier
    if type(items) ~= "table" then return false end
    for _, v in pairs(items) do
        tgiann:AddItemToSecondaryInventory("trunk", identifier, v.item, v.count, nil, v.metadata)
    end
    return true
end

---This will clear the specified inventory, will always return true unless a value isnt passed correctly.
---@param id string
---@return boolean
Inventory.ClearStash = function(id, _type)
    if type(id) ~= "string" then return false end
    tgiann:DeleteInventory(_type, id)
    if Inventory.Stashes[id] then Inventory.Stashes[id] = nil end
    return true
end

---This will get the image path for an item, it is an alternate option to GetItemInfo. If a image isnt found will revert to community_bridge logo (useful for menus)
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local pngPath = LoadResourceFile("inventory_images", string.format("html/images/%s.png", item))
    local webpPath = LoadResourceFile("inventory_images", string.format("html/images/%s.webp", item))
    local imagePath = pngPath and string.format("nui://inventory_images/html/images/%s.png", item) or webpPath and string.format("nui://inventory_images/html/images/%s.webp", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end


---UNUSED:
---This will return generic item data from the specified inventory, with the items total count.
---
---format without metadata { count, stack, name, weight, label }
---
---fortmat with metadata { count, stack, name, weight, label, metadata }
---@param src number
---@param item string
---@param metadata table
---@return table
Inventory.GetItem = function(src, item, metadata)
    local item = tgiann:GetItemByName(src, item, metadata)
    item.count = item.amount
    item.metadata = item.info
    return item
end

return Inventory