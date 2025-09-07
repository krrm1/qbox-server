---@diagnostic disable: duplicate-set-field
Skills = Skills or {}
Skills.All = Skills.All or {}

-- XP Cache for performance
local XP_CACHE = {}

-- Default skill object: currentXP (0 to required), level
local DEFAULT_SKILL = { currentXP = 0, level = 1 }

-- Helper function to get or create a skill object
local function getOrCreateSkill(src, skillName)
    if not src or not skillName then return table.clone(DEFAULT_SKILL) end

    local playerSkills = Framework.GetPlayerMetadata(src, "community_bridge_skills") or {}
    if not playerSkills[skillName] then
        playerSkills[skillName] = table.clone(DEFAULT_SKILL)
    end

    return playerSkills[skillName]
end

-- Calculate XP required for a level using RuneScape algorithm (with caching)
Skills.GetXPForLevel = function(level)
    if not level or level < 1 then return 0 end
    if level == 1 then return 0 end  -- Level 1 requires 0 XP

    -- Check cache first
    if XP_CACHE[level] then
        return XP_CACHE[level]
    end

    -- Calculate and cache
    local xp = 0
    for n = 1, level - 1 do
        xp = xp + math.floor(n + 300 * (2 ^ (n / 7)))
    end
    local result = math.floor(xp / 4)
    XP_CACHE[level] = result

    return result
end

-- Create a skill (for initialization)
Skills.Create = function(name, maxLevel, baseXP)
    if not name then return end
    Skills.All[name] = { name = name, maxLevel = maxLevel or 99, baseXP = baseXP or 50 }
    return Skills.All[name]
end

-- Get player's current level
Skills.GetSkillLevel = function(src, skillName)
    if not src or not skillName then return 1 end
    local skill = getOrCreateSkill(src, skillName)
    return skill.level or 1
end

Skills.GetScaledXP = function(baseXP, playerLevel)
    return math.floor(baseXP * (1 + playerLevel * 0.05))
end
-- Get current XP (0 to required XP for current level)
Skills.GetXP = function(src, skillName)
    if not src or not skillName then return 0 end
    local skill = getOrCreateSkill(src, skillName)
    local currentXP = skill.currentXP or 0
    return currentXP
end

-- Get XP required to complete the current level
Skills.GetXPRequiredForLevel = function(level)
    if not level or level < 1 then return 0 end
    if level == 1 then return 83 end  -- Level 1 to 2 requires 83 XP
    return Skills.GetXPForLevel(level)
end

-- Add XP and handle level ups
Skills.AddXP = function(src, skillName, xp)
    if not src or not skillName then
        return false
    end

    if not xp or xp <= 0 then
        xp = Skills.GetScaledXP(50, Skills.GetSkillLevel(src, skillName))
    end

    local playerSkills = Framework.GetPlayerMetadata(src, "community_bridge_skills") or {}
    local skill = playerSkills[skillName]
    if not skill then
        skill = table.clone(DEFAULT_SKILL)
        playerSkills[skillName] = skill
    end

    local oldLevel = skill.level or 1
    local currentXP = skill.currentXP or 0
    -- Add XP
    currentXP = currentXP + xp


    local xpNeeded = Skills.GetXPRequiredForLevel(oldLevel + 1)
    if currentXP >= xpNeeded then
        currentXP = currentXP - xpNeeded
        oldLevel = oldLevel + 1
    end

    skill.level = oldLevel
    skill.currentXP = currentXP
    playerSkills[skillName] = skill

    Framework.SetPlayerMetadata(src, "community_bridge_skills", playerSkills)

    return true, oldLevel, currentXP
end

-- Set skill level directly (resets currentXP to 0)
Skills.SetSkillLevel = function(src, skillName, level)
    if not src or not skillName or not level or level < 1 then return false end

    local playerSkills = Framework.GetPlayerMetadata(src, "community_bridge_skills") or {}
    local skill = playerSkills[skillName] or table.clone(DEFAULT_SKILL)

    level = math.min(math.max(1, level), 99)
    skill.level = level
    skill.currentXP = 0

    playerSkills[skillName] = skill
    Framework.SetPlayerMetadata(src, "community_bridge_skills", playerSkills)
    return true
end

-- Set current XP directly
Skills.SetXP = function(src, skillName, xp)
    if not src or not skillName or not xp or xp < 0 then return false end

    local playerSkills = Framework.GetPlayerMetadata(src, "community_bridge_skills") or {}
    local skill = playerSkills[skillName] or table.clone(DEFAULT_SKILL)

    skill.currentXP = xp
    playerSkills[skillName] = skill

    Framework.SetPlayerMetadata(src, "community_bridge_skills", playerSkills)
    return true
end

-- Get resource name
Skills.GetResourceName = function()
    return "community_bridge"
end

-- Debug Commands
-- RegisterCommand('clearskill', function(source, args, rawCommand)
--     if not source or source == 0 then return end
--     local skillName = args[1] or "fishing"
--     Skills.SetXP(source, skillName, 0)
--     Skills.SetSkillLevel(source, skillName, 1)
--     print("Skill " .. skillName .. " cleared for player " .. source)
-- end, false)

return Skills