Logs = Logs or {}

local WebhookURL = "" -- Add webhook URL here if using built-in logging system
local LogoForEmbed = "https://cdn.discordapp.com/avatars/299410129982455808/31ce635662206e8bd0132c34ce9ce683?size=1024"
local LogSystem = "built-in" -- Default log system, can be "built-in", "qb", or "ox_lib"


---This will send a log to the configured webhook or log system.
---@param src number
---@param message string
---@return nil
Logs.Send = function(src, message)
    if not src or not message then return end
    local logType = LogSystem or "built-in"
    if logType == "built-in" then
        PerformHttpRequest(WebhookURL, function(err, text, headers) end, 'POST', json.encode(
        {
            username = "Community_Bridge's Logger",
            avatar_url = 'https://avatars.githubusercontent.com/u/192999457?s=400&u=da632e8f64c85def390cfd1a73c3b664d6882b38&v=4',
            embeds = {
                {
                    color = "15769093",
                    title = GetCurrentResourceName(),
                    url = 'https://discord.gg/Gm6rYEXUsn',
                    thumbnail = { url = LogoForEmbed },
                    fields = {
                        {
                            name = '**Player ID**',
                            value = src,
                            inline = true,
                        },
                        {
                            name = '**Player Identifier**',
                            value = Framework.GetPlayerIdentifier(src),
                            inline = true,
                        },
                        {
                            name = 'Log Message',
                            value = "```"..message.."```",
                            inline = false,
                        },
                    },
                    timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
                    footer = {
                        text = "Community_Bridge | ",
                        icon_url = 'https://avatars.githubusercontent.com/u/192999457?s=400&u=da632e8f64c85def390cfd1a73c3b664d6882b38&v=4',
                    },
                }
            }
        }), { ['Content-Type']= 'application/json' })
    elseif logType == "qb" then
        return TriggerEvent('qb-log:server:CreateLog', GetCurrentResourceName(), GetCurrentResourceName(), 'green', message)
    elseif logType == "ox_lib" then
        return lib.logger(src, GetCurrentResourceName(), message)
    end
end

exports('Logs', Logs)
return Logs
