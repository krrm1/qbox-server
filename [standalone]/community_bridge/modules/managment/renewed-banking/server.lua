---@diagnostic disable: duplicate-set-field
if GetResourceState('Renewed-Banking') == 'missing' then return end
Managment = Managment or {}

local renewed = exports['Renewed-Banking']

---This will get the name of the Managment system being being used.
---@return string
Managment.GetManagmentName = function()
    return 'Renewed-Banking'
end

---This will return a number
---@param account string
---@return number
Managment.GetAccountMoney = function(account)
    return renewed:getAccountMoney(account)
end

---This will add money to the specified account of the passed amount
---@param account string
---@param amount number
---@param _ string
---@return boolean
Managment.AddAccountMoney = function(account, amount, _)
    return renewed:addAccountMoney(account, amount)
end

---This will remove money from the specified account of the passed amount
---@param account string
---@param amount number
---@param _ string
---@return boolean
Managment.RemoveAccountMoney = function(account, amount, _)
    return renewed:removeAccountMoney(account, amount)
end

return Managment