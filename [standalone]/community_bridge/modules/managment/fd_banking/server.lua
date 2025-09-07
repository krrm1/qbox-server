---@diagnostic disable: duplicate-set-field
if GetResourceState('fd_banking') == 'missing' then return end
Managment = Managment or {}

local fd_banking = exports['fd_banking']

---This will get the name of the Managment system being being used.
---@return string
Managment.GetManagmentName = function()
    return 'fd_banking'
end

---This will return a number
---@param account string
---@return number
Managment.GetAccountMoney = function(account)
    return fd_banking:GetAccount(account)
end

---This will add money to the specified account of the passed amount
---@param account string
---@param amount number
---@param reason string
---@return boolean
Managment.AddAccountMoney = function(account, amount, reason)
    return fd_banking:AddMoney(account, amount, reason)
end

---This will remove money from the specified account of the passed amount
---@param account string
---@param amount number
---@param reason string
---@return boolean
Managment.RemoveAccountMoney = function(account, amount, reason)
    return fd_banking:RemoveMoney(account, amount, reason)
end

return Managment