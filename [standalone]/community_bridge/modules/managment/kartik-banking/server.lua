---@diagnostic disable: duplicate-set-field
if GetResourceState('kartik-banking') == 'missing' then return end
Managment = Managment or {}

local kartik = exports['kartik-banking']

---This will get the name of the Managment system being being used.
---@return string
Managment.GetManagmentName = function()
    return 'kartik-banking'
end

---This will return a number
---@param account string
---@return number
Managment.GetAccountMoney = function(account)
    local balance = kartik:GetAccountMoney(account)
    return balance or 0
end

---This will add money to the specified account of the passed amount
---@param account string
---@param amount number
---@param reason string
---@return boolean
Managment.AddAccountMoney = function(account, amount, reason)
    return kartik:AddAccountMoney(account, amount, reason)
end

---This will remove money from the specified account of the passed amount
---@param account string
---@param amount number
---@param reason string
---@return boolean
Managment.RemoveAccountMoney = function(account, amount, reason)
    return kartik:RemoveAccountMoney(account, amount, reason)
end

return Managment
