local module = {}

module.emotes = {
    dances = {"dance1", "dance2", "dance3"},
    -- Existance in this list signifies that it is an emote, the value indicates if it is a looping emote
    emoteNames = { wave = false, point = false, dance1 = true, dance2 = true, dance3 = true, laugh = false, cheer = false},
    emotes = {
        wave = {
            { id = "http://www.roblox.com/asset/?id=507770239", weight = 10 } 
        },
        point = {
                    { id = "http://www.roblox.com/asset/?id=507770453", weight = 10 } 
        },
        dance = {
                    { id = "http://www.roblox.com/asset/?id=507771019", weight = 10 }, 
                    { id = "http://www.roblox.com/asset/?id=507771955", weight = 10 }, 
                    { id = "http://www.roblox.com/asset/?id=507772104", weight = 10 } 
        },
        dance2 = {
                    { id = "http://www.roblox.com/asset/?id=507776043", weight = 10 }, 
                    { id = "http://www.roblox.com/asset/?id=507776720", weight = 10 }, 
                    { id = "http://www.roblox.com/asset/?id=507776879", weight = 10 } 
        },
        dance3 = {
                    { id = "http://www.roblox.com/asset/?id=507777268", weight = 10 }, 
                    { id = "http://www.roblox.com/asset/?id=507777451", weight = 10 }, 
                    { id = "http://www.roblox.com/asset/?id=507777623", weight = 10 } 
        },
        laugh = {
                    { id = "http://www.roblox.com/asset/?id=507770818", weight = 10 } 
        },
        cheer = {
                    { id = "http://www.roblox.com/asset/?id=507770677", weight = 10 } 
        },
    }
}

module.defaultCoreAnimations = {
	idle = 	{	
        { id = "rbxassetid://10921259953", weight = 9 },
        { id = "rbxassetid://10921258489", weight = 1 },
    },
    walk = 	{ 	
            { id = "rbxassetid://507777826", weight = 10 } 
    },
    run = 	{
            { id = "rbxassetid://507767714", weight = 10 } 
    },
    swim = 	{
            { id = "http://www.roblox.com/asset/?id=507784897", weight = 10 } 
    }, 
    swimidle = 	{
            { id = "http://www.roblox.com/asset/?id=507785072", weight = 10 } 
    }, 
    jump = 	{
            { id = "http://www.roblox.com/asset/?id=15760935148", weight = 10 } 
    }, 
    fall = 	{
            { id = "http://www.roblox.com/asset/?id=15760926079", weight = 10 } 
    }, 
    climb = {
            { id = "http://www.roblox.com/asset/?id=15943887134", weight = 10 } 
    }, 
    sit = 	{
            { id = "http://www.roblox.com/asset/?id=2506281703", weight = 10 } 
    },	
}

module.monsterCoreAnimations = {
    -- Monster
    idle = 	{	
        { id = "http://www.roblox.com/asset/?id=18444201906", weight = 9 },
        { id = "http://www.roblox.com/asset/?id=18444212045", weight = 1 },
    },
    walk = 	{ 	
        { id = "rbxassetid://18444021009", weight = 10 } 
    }, 
    run = 	{
            { id = "rbxassetid://18444014491", weight = 10 } 
    }, 
    swim = 	{
            { id = "http://www.roblox.com/asset/?id=507784897", weight = 10 } 
    }, 
    swimidle = 	{
            { id = "http://www.roblox.com/asset/?id=507785072", weight = 10 } 
    }, 
    jump = 	{
        { id = "rbxassetid://1083218792", weight = 10 } 
    }, 
    fall = 	{
            { id = "http://www.roblox.com/asset/?id=15760926079", weight = 10 } 
    }, 
    climb = {
            { id = "http://www.roblox.com/asset/?id=15943887134", weight = 10 } 
    }, 
    sit = 	{
            { id = "http://www.roblox.com/asset/?id=2506281703", weight = 10 } 
    },	
}

return module