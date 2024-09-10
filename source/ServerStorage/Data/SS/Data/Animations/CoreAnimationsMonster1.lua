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
        { id = "rbxassetid://17266082847", weight = 10 }
    },
    walk = 	{ 	
            { id = "rbxassetid://17266119232", weight = 10 } 
    }, 
    run = 	{
            { id = "rbxassetid://17266121985", weight = 10 } 
    }, 
    swim = 	{
            { id = "rbxassetid://17266121985", weight = 10 } 
    }, 
    swimidle = 	{
            { id = "rbxassetid://17266082847", weight = 10 } 
    }, 
    jump = 	{
            { id = "rbxassetid://17266108815", weight = 10 } 
    }, 
    fall = 	{
            { id = "rbxassetid://17266061794", weight = 10 } 
    }, 
    climb = {
            { id = "rbxassetid://17266067622", weight = 10 } 
    }, 
    sit = 	{
            { id = "http://www.roblox.com/asset/?id=2506281703", weight = 10 } 
    },	
}

return module