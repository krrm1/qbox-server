---@diagnostic disable: duplicate-set-field
if GetResourceState('qb-banking') == 'missing' then return end
Managment = Managment or {}

local qbBanking = exports['qb-banking']

---This will get the name of the Managment system being being used.
---@return string
Managment.GetManagmentName = function()
    return 'qb-banking'
end

---This will return a number
---@param account string
---@return number
Managment.GetAccountMoney = function(account)
    return qbBanking:GetAccountBalance(account)
end

---This will add money to the specified account of the passed amount
---@param account string
---@param amount number
---@param reason string
---@return boolean
Managment.AddAccountMoney = function(account, amount, reason)
    return qbBanking:AddMoney(account, amount, reason)
end

---This will remove money from the specified account of the passed amount
---@param account string
---@param amount number
---@param reason string
---@return boolean
Managment.RemoveAccountMoney = function(account, amount, reason)
    return qbBanking:RemoveMoney(account, amount, reason)
end

return Managment