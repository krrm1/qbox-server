---@diagnostic disable: duplicate-set-field
Skills = Skills or {}

---This will get the name of the Skills system being being used.
---@return string
Skills.GetResourceName = function()
    return "community_bridge"
end

---This will get the skill level of the passed skill name. (returns 1 if not found)
---@param skillName string
---@return number
Skills.GetSkillLevel = function(skillName)
    if not skillName then return 0 end
    local plyrSkills = Framework.GetPlayerMetaData("community_bridge_skills")
    if not plyrSkills or not plyrSkills[skillName] then return 1 end
    return plyrSkills[skillName].level or 1
end

-- RegisterCommand("getfishingLevel", function(source, args)
--     local level = Skills.GetSkillLevel("fishing")
--     print("Client Fishing Level issssssssss  " .. level)
-- end, false)

return Skills