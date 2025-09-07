-- Grid-based point system
Point = {}
local ActivePoints = {}
local GridCells = {}
local LoopStarted = false
local insidePoints = {}
local data = {} -- 👈 Move this outside the function

-- Grid configuration
local GRID_SIZE = 500.0 -- Size of each grid cell
local CELL_BUFFER = 1 -- Number of adjacent cells to check

-- Consider adding these optimizations
local ADAPTIVE_WAIT = true -- Adjust wait time based on player speed

---This is an internal function, do not call this externally
function Point.GetCellKey(coords)
    local cellX = math.floor(coords.x / GRID_SIZE)
    local cellY = math.floor(coords.y / GRID_SIZE)
    return cellX .. ":" .. cellY
end

---This is an internal function, do not call this externally
function Point.RegisterInGrid(point)
    local cellKey = Point.GetCellKey(point.coords)

    -- Initialize cell if it doesn't exist
    GridCells[cellKey] = GridCells[cellKey] or {
        points = {},
        count = 0
    }

    -- Add point to cell
    GridCells[cellKey].points[point.id] = point
    GridCells[cellKey].count = GridCells[cellKey].count + 1

    -- Store cell reference in point
    point.cellKey = cellKey
end

---This is an internal function, do not call this externally
function Point.UpdateInGrid(point, oldCellKey)
    -- Remove from old cell if cell key changed
    if oldCellKey and oldCellKey ~= point.cellKey then
        if GridCells[oldCellKey] and GridCells[oldCellKey].points[point.id] then
            GridCells[oldCellKey].points[point.id] = nil
            GridCells[oldCellKey].count = GridCells[oldCellKey].count - 1

            -- Clean up empty cells
            if GridCells[oldCellKey].count <= 0 then
                GridCells[oldCellKey] = nil
            end
        end

        -- Add to new cell
        Point.RegisterInGrid(point)
    end
end

---Gets nearby cells based on the coords
---@param coords table
---@return table
function Point.GetNearbyCells(coords)
    local cellX = math.floor(coords.x / GRID_SIZE)
    local cellY = math.floor(coords.y / GRID_SIZE)
    local nearbyCells = {}

    -- Get current and adjacent cells
    for x = cellX - CELL_BUFFER, cellX + CELL_BUFFER do
        for y = cellY - CELL_BUFFER, cellY + CELL_BUFFER do
            local key = x .. ":" .. y
            if GridCells[key] then
                table.insert(nearbyCells, key)
            end
        end
    end

    return nearbyCells
end

---Returns all points in the same cell as the given point
---This will require you to pass the point object
---@param point table
---@return table
function Point.CheckPointsInSameCell(point)
    local cellKey = point.cellKey
    if not GridCells[cellKey] then return {} end

    local nearbyPoints = {}
    for id, otherPoint in pairs(GridCells[cellKey].points) do
        if id ~= point.id then
            local distance = #(point.coords - otherPoint.coords)
            if distance < (point.distance + otherPoint.distance) then
                nearbyPoints[id] = otherPoint
            end
        end
    end

    return nearbyPoints
end

---Internal function that starts the loop. Do not call this function directly.
function Point.StartLoop()
    if LoopStarted then return false end
    LoopStarted = true
    -- Remove the "local data = {}" line from here
    CreateThread(function()
        while LoopStarted do
            local playerPed = PlayerPedId()
            while playerPed == -1 do
                Wait(100)
                playerPed = PlayerPedId()
            end
            local playerCoords = GetEntityCoords(playerPed)
            local targetsExist = false
            local playerCellKey = Point.GetCellKey(playerCoords)
            local nearbyCells = Point.GetNearbyCells(playerCoords)

            local playerSpeed = GetEntitySpeed(playerPed)
            local maxWeight = 1000
            local waitTime = ADAPTIVE_WAIT and math.max(maxWeight/10, maxWeight - playerSpeed * maxWeight/10) or maxWeight
            -- Process only points in nearby cells
            for _, cellKey in ipairs(nearbyCells) do
                if GridCells[cellKey] then
                    for id, point in pairs(GridCells[cellKey].points) do
                        targetsExist = true

                        -- Update entity position if needed
                        local oldCellKey = point.cellKey
                        if point.isEntity then
                            point.coords = GetEntityCoords(point.target)
                            point.cellKey = Point.GetCellKey(point.coords)
                            Point.UpdateInGrid(point, oldCellKey)
                        end
                        local coords = point.coords and vector3(point.coords.x, point.coords.y, point.coords.z) or vector3(0, 0, 0)
                        local distance = #(playerCoords - coords)
                        --local distance = #(playerCoords - point.coords)

                        -- Check if player entered/exited the point
                        if distance < point.distance then
                            if not point.inside then
                                point.inside = true
                                data[point.id] = data[point.id] or point.args or {}
                                data[point.id] = point.onEnter(point, data[point.id])
                                insidePoints[point.id] = point
                            end
                        -- Modified main loop exit handler
                        elseif point.inside then
                            point.inside = false
                            data[point.id] = data[point.id] or point.args or {}
                            local result = point.onExit(point, data[point.id])
                            data[point.id] = result ~= nil and result or data[point.id]  -- ← Use consistent fallback
                            point.args = data[point.id]  -- ← Update point.args to match data[point.id]
                            insidePoints[point.id] = nil
                        end
                        
                        if point.onNearby then
                            point.onNearby(GridCells[cellKey]?.points, waitTime)
                        end
                    end
                end
            end

            for id, insidepoint in pairs(insidePoints) do
                local pos = insidepoint.coords and vector3(insidepoint.coords.x, insidepoint.coords.y, insidepoint.coords.z) or vector3(0, 0, 0)
                local dist = #(playerCoords - pos)
                if dist > insidepoint.distance then
                    insidepoint.inside = false
                    data[insidepoint.id] = data[insidepoint.id] or insidepoint.args or {}
                    local result = insidepoint.onExit(insidepoint, data[insidepoint.id])
                    data[insidepoint.id] = result ~= nil and result or data[insidepoint.id]
                    insidepoint.args = data[insidepoint.id]  -- ← Keep data in sync
                    insidePoints[insidepoint.id] = nil
                end
            end
            Wait(waitTime) -- Faster updates when moving quickly
        end
    end)
    return true
end

---Create a point based on a vector or entityID
---@param id string
---@param target number || vector3
---@param distance number
---@param _onEnter function
---@param _onExit function
---@param _onNearby function
---@param data self
---@return table
function Point.Register(id, target, distance, args, _onEnter, _onExit, _onNearby)
    local isEntity = type(target) == "number"
    local coords = isEntity and GetEntityCoords(target) or target

    local self = {}
    self.id = id
    self.target = target -- Store entity ID or Vector3
    self.isEntity = isEntity
    self.coords = coords
    self.distance = distance
    self.onEnter = _onEnter or function() end
    self.onExit = _onExit or function() end
    self.onNearby = _onNearby or function() end
    self.inside = false -- Track if player is inside
    self.args = args or {}

    ActivePoints[id] = self
    Point.RegisterInGrid(self)
    Point.StartLoop()
    return self
end

---Remove an exsisting point by its id
---@param id string
function Point.Remove(id)
    local point = ActivePoints[id]
    if point then
        local cellKey = point.cellKey
        if GridCells[cellKey] and GridCells[cellKey].points[id] then
            GridCells[cellKey].points[id] = nil
            GridCells[cellKey].count = GridCells[cellKey].count - 1

            if GridCells[cellKey].count <= 0 then
                GridCells[cellKey] = nil
            end
        end

        ActivePoints[id] = nil
    end
end

---Returnes a point by its id
---@param id string
---@return table
function Point.Get(id)
    return ActivePoints[id]
end

function Point.UpdateCoords(id, coords)
    local point = ActivePoints[id]
    if point then
        point.coords = coords
        local oldCellKey = point.cellKey
        point.cellKey = Point.GetCellKey(coords)
        Point.UpdateInGrid(point, oldCellKey)
    end
end

---Returns all points
---@return table
function Point.GetAll()
    return ActivePoints
end

return Point