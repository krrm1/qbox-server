---@diagnostic disable: duplicate-set-field

Skills = Skills or {}
local resourceName = "OT_skills"
local configValue = BridgeSharedConfig.Skills
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

---This will return the name of the Skills system being used.
---@return string
Skills.GetResourceName = function()
    return resourceName
end

---This will return the skill level of the passed skill name.
---@param skillName string
---@return number
Skills.GetSkillLevel = function(skillName)
    local skillData = exports.OT_skills:getSkill(skillName)
    return skillData.level or 0
end

return Skills