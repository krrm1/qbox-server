if GetResourceState('ps-dispatch') == 'missing' then return end
if GetResourceState('lb-tablet') == 'started' then return end
Dispatch = Dispatch or {}

return Dispatch