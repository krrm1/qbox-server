---@diagnostic disable: duplicate-set-field
if GetResourceState('tgiann-bank') == 'missing' then return end
Managment = Managment or {}

local tgiann = exports["tgiann-bank"]

---This will get the name of the Managment system being being used.
---@return string
Managment.GetManagmentName = function()
    return 'tgiann-bank'
end

---This will return a number
---@param account string
---@return number
Managment.GetAccountMoney = function(account)
    return tgiann:GetJobAccountBalance(account)
end

---This will add money to the specified account of the passed amount
---@param account string
---@param amount number
---@param _ string
---@return boolean
Managment.AddAccountMoney = function(account, amount, _)
    return tgiann:AddJobMoney(account, amount)
end

---This will remove money from the specified account of the passed amount
---@param account string
---@param amount number
---@param _ string
---@return boolean
Managment.RemoveAccountMoney = function(account, amount, _)
    return tgiann:RemoveJobMoney(account, amount)
end

return Managment