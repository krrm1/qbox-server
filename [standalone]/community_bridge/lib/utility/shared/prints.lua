Prints = Prints or {}
local function printMessage(level, color, message)
    if type(message) == 'table' then
        message = json.encode(message)
    end
    print(color .. '[' .. level .. ']:', message)
end


---This will print a colored message to the console with the designated prefix.
---@param message string
Prints.Info = function(message)
    printMessage('INFO', '^5', message)
end

---This will print a colored message to the console with the designated prefix.
---@param message string
Prints.Warn = function(message)
    printMessage('WARN', '^3', message)
end

---This will print a colored message to the console with the designated prefix.
---@param message string
Prints.Error = function(message)
    printMessage('ERROR', '^1', message)
end

---This will print a colored message to the console with the designated prefix.
---@param message string
Prints.Debug = function(message)
    printMessage('DEBUG', '^2', message)
end

return Prints