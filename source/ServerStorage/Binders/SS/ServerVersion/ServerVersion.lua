local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local GameData = Data.Game.Game

local ServerVersion = {}
ServerVersion.__index = ServerVersion
ServerVersion.className = "ServerVersion"
ServerVersion.TAG_NAME = ServerVersion.className

function ServerVersion.new(text)
    text.Text = ("Server Version %s"):format(GameData.version)
    return
end

function ServerVersion:Destroy()

end

return ServerVersion