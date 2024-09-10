local Data = script:FindFirstAncestor("Data")
local GameData = require(Data.Game.Game)
local SocialCodes = require(Data.SocialCodes.SocialCodes)

local module = {}

module["1"] = {
    message = {
        Text="New update",
        RichText = true,
    },
    LayoutOrder = 1,
}

return module