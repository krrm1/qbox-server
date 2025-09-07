---@diagnostic disable: duplicate-set-field
if GetResourceState('origen_inventory') ~= 'started' then return end

Inventory = Inventory or {}
Inventory.Stashes = Inventory.Stashes or {}

local origin = exports.origen_inventory

---This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number
---@param metadata table
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = count, slot = slot, metadata = metadata})
    return origin:AddItem(src, item, count, metadata, slot, true)
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
    return origin:removeItem(src, item, count, metadata, slot, true)
end

---This will add items to a trunk, and return true or false based on success
---@param identifier string
---@param items table
---@return boolean
Inventory.AddTrunkItems = function(identifier, items)
    local id = "trunk_"..identifier
    if type(items) ~= "table" then return false end
    Inventory.RegisterStash(id, identifier, 20, 10000, nil, nil, nil)
    local repack_items = {}
    for _, v in pairs(items) do
        table.insert(repack_items, {
            name = v.item,
            amount = v.count,
            metadata = v.metadata or {}
        })
    end
    if #repack_items == 0 then return false end
    origin:addItems(id, repack_items)
    return true
end

---This will clear the specified inventory, will always return true unless a value isnt passed correctly.
---@param identifier string
---@return boolean
Inventory.ClearStash = function(identifier, _type)
    if type(identifier) ~= "string" then return false end
    if Inventory.Stashes[identifier] then Inventory.Stashes[identifier] = nil end
    local id = identifier
    if _type == "trunk" then
        id = "trunk_"..id
    elseif _type == "glovebox" then
        id = "glovebox_"..id
    elseif _type == "stash" then
        id = "stash_"..id
    end
    local inv = origin:getInventory(identifier, _type)
    if not inv then return false end
    local indexed = inv.inventory
    for _, v in pairs(indexed) do
        if v.slot then
            origin:removeItem(id, v.name, v.amount, nil, v.slot)
        end
    end
    return true
end

---This will return a table with the item info, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemData = origin:Items(item)
    if not itemData then return {} end
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
    return origin:Items()
end

---This will return the count of the item in the players inventory, if not found will return 0.
---if metadata is passed it will find the matching items count.
---@param src number
---@param item string
---@param metadata table
---@return number
Inventory.GetItemCount = function(src, item, metadata)
    return origin:getItemCount(src, item, metadata, false) or 0
end

---This wil return the players inventory.
---@param src number
---@return table
Inventory.GetPlayerInventory = function(src)
    local playerInv = origin:GetInventory(src)
    local inv = playerInv.inventory or {}
    local repack = {}
    for _, v in pairs(inv) do
        if v.slot then
            table.insert(repack, {
                name = v.name,
                count = v.amount,
                metadata = v.metadata or {},
                slot = v.slot,
                label = v.label or "Unknown"
            })
        end
    end
    return repack
end

---Returns the specified slot data as a table.
---format {weight, name, metadata, slot, label, count}
---@param src number
---@param slot number
---@return table
Inventory.GetItemBySlot = function(src, slot)
    local playerInv = Inventory.GetPlayerInventory(src)
    for _, v in pairs(playerInv) do
        if v.slot == slot then
            return {
                name = v.name,
                count = v.count,
                weight = v.weight or 0,
                metadata = v.metadata,
                slot = v.slot,
                label = v.label
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
    origin:setMetadata(src, slot, metadata)
end

---This will open the specified stash for the src passed.
---@param src number
---@param _type string
---@param id number|string
---@return nil
Inventory.OpenStash = function(src, _type, id)
    _type = _type or "stash"
    local tbl = Inventory.Stashes[id]
    return origin:OpenInventory(src, _type, id)
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
    origin:registerStash(id, label, slots, weight, owner, groups, coords)
    return true, id
end

---This will return a boolean if the player has the item.
---@param src number
---@param item string
---@return boolean
Inventory.HasItem = function(src, item)
    return origin:getItemCount(src , item) > 0
end

---This is to get if there is available space in the inventory, will return boolean.
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    return origin:canCarryItem(src, item, count)
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
    local file = LoadResourceFile("origin", string.format("html/images/%s.png", item))
    local imagePath = file and string.format("nui://origen_inventory/html/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

return Inventory