---@diagnostic disable: duplicate-set-field
Managment = Managment or {}

---This will get the name of the Managment system being being used.
---@return string
Managment.GetManagmentName = function()
    return 'default'
end

---This will return a number
---@param account string
---@return number
Managment.GetAccountMoney = function(account)
    return 0, print("The resource you are using does not support this function.")
end

---This will add money to the specified account of the passed amount
---@param account string
---@param amount number
---@param reason string
---@return boolean
Managment.AddAccountMoney = function(account, amount, reason)
    return false, print("The resource you are using does not support this function.")
end

---This will remove money from the specified account of the passed amount
---@param account string
---@param amount number
---@param reason string
---@return boolean
Managment.RemoveAccountMoney = function(account, amount, reason)
    return false, print("The resource you are using does not support this function.")
end

return Managment