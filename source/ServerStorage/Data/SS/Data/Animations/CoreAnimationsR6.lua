local module = {}

module.config = {
    jumpAnimDuration = 0.3,
    toolTransitionTime = 0.1,
    fallTransitionTime = 0.3,
}

module.emotes = {
    dances = {"dance1", "dance2", "dance3"},
    -- Existance in this list signifies that it is an emote, the value indicates if it is a looping emote
    emoteNames = { wave = false, point = false, dance1 = true, dance2 = true, dance3 = true, laugh = false, cheer = false},
    emotes = {
        wave = {
            { id = "http://www.roblox.com/asset/?id=128777973", weight = 10 } 
        },
        point = {
                    { id = "http://www.roblox.com/asset/?id=128853357", weight = 10 } 
                },
        dance1 = {
                    { id = "http://www.roblox.com/asset/?id=182435998", weight = 10 }, 
                    { id = "http://www.roblox.com/asset/?id=182491037", weight = 10 }, 
                    { id = "http://www.roblox.com/asset/?id=182491065", weight = 10 } 
                },
        dance2 = {
                    { id = "http://www.roblox.com/asset/?id=182436842", weight = 10 }, 
                    { id = "http://www.roblox.com/asset/?id=182491248", weight = 10 }, 
                    { id = "http://www.roblox.com/asset/?id=182491277", weight = 10 } 
                },
        dance3 = {
                    { id = "http://www.roblox.com/asset/?id=182436935", weight = 10 }, 
                    { id = "http://www.roblox.com/asset/?id=182491368", weight = 10 }, 
                    { id = "http://www.roblox.com/asset/?id=182491423", weight = 10 } 
                },
        laugh = {
                    { id = "http://www.roblox.com/asset/?id=129423131", weight = 10 } 
                },
        cheer = {
                    { id = "http://www.roblox.com/asset/?id=129423030", weight = 10 } 
                },
            }
}

module.defaultCoreAnimations = {
    idle = 	{
                { id = "http://www.roblox.com/asset/?id=180435571", weight = 9 },
                { id = "http://www.roblox.com/asset/?id=180435792", weight = 1 }
            },
    walk = 	{
                { id = "http://www.roblox.com/asset/?id=180426354", weight = 10 } 
            },
    run = 	{
                { id = "run.xml", weight = 10 }
            },
    jump = 	{
                { id = "http://www.roblox.com/asset/?id=125750702", weight = 10 } 
            },
    fall = 	{
                { id = "http://www.roblox.com/asset/?id=180436148", weight = 10 } 
            },
    climb = {
                { id = "http://www.roblox.com/asset/?id=180436334", weight = 10 } 
            },
    sit = 	{
                { id = "http://www.roblox.com/asset/?id=178130996", weight = 10 } 
            },
    toolnone = {
                { id = "http://www.roblox.com/asset/?id=182393478", weight = 10 } 
            },
    toolslash = {
                { id = "http://www.roblox.com/asset/?id=129967390", weight = 10 } 
--				{ id = "slash.xml", weight = 10 }
            },
    toollunge = {
                { id = "http://www.roblox.com/asset/?id=129967478", weight = 10 } 
            },
}

return module