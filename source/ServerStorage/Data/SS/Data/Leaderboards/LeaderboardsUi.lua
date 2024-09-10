local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")

local Data = script:FindFirstAncestor("Data")
local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})
local PrettyNames = require(Data.Strings.PrettyNames)
local MoneyData = require(Data.Money.Money)
local S = require(Data.Strings.Strings)

local module = {}

module["1"] = {
    Title = ("Top %s"):format(MoneyData[S.Money_1].prettyName),
}

module["2"] = {
    Title = ("Top %s"):format(PrettyNames[S.FinishChapter]),
}

module["3"] = {
    Title = ("Top %s"):format(PrettyNames[S.FinishChapter1]),
}

module["4"] = {
    Title = ("Top %s"):format(PrettyNames[S.Kills]),
}

for id, data in pairs(module) do
    data.TitleStyle = data.TitleStyle or {}
    TableUtils.setProto(data.TitleStyle, {
        TextColor3=Color3.fromRGB(255, 255,255),
    })
    data.EntryStyle = data.EntryStyle or {}
    TableUtils.setProto(data.EntryStyle, {
        TextColor3=Color3.fromRGB(255, 255,255),
    })
end

return module