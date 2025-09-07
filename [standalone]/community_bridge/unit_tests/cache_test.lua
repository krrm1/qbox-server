AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Bridge.Cache.OnChange("Ped", function(newValue, oldValue)
            print("Ped changed from " .. tostring(oldValue) .. " to " .. tostring(newValue))
        end)
    end
end)


RegisterCommand("testcache", function(source, args, rawCommand)
    -- local cache = Bridge.Cache.Get("Ped")
    Bridge.Cache.Create("TestCache", function()
        return math.random(1, 100)
    end, 1000)
    
    Bridge.Cache.OnChange("TestCache", function(newValue, oldValue)
        print("TestCache changed from " .. tostring(oldValue) .. " to " .. tostring(newValue))
    end)
end)