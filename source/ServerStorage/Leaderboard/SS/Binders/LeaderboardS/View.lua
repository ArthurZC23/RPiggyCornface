local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local LeaderboardsUi = Data.Leaderboards.LeaderboardsUi
local S = Data.Strings.Strings
local ScoresData = Data.Scores.Scores
local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})
local TableUtils = Mod:find({"Table", "Utils"})

local View = {}
View.__index = View
View.className = "View"
View.TAG_NAME = View.className

function View.new(leaderboardObj)
    local self = {
        _maid = Maid.new(),
        leaderboardObj = leaderboardObj,
        leaderboard = leaderboardObj.leaderboard,
    }
    setmetatable(self, View)

    self:setTitle()
    self:setEntryDefaultStyle()
    self:setScoreType()
    self:createEntryGuiObjs()

    return self
end

function View:setTitle()
    self.TitleFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=self.leaderboard, refName="Title"})
    local leaderboardUi = LeaderboardsUi[self.leaderboardObj.id]
    self.TitleFrame.Title.Text = leaderboardUi.Title
    TableUtils.setInstance(self.TitleFrame.Title, leaderboardUi.TitleStyle)
end

function View:setEntryDefaultStyle()
    self.entryTemplate = SharedSherlock:find({"EzRef", "Get"}, {inst=self.leaderboard, refName="EntryTemplate"})
    for _, desc in ipairs(self.entryTemplate:GetDescendants()) do
        if not desc:IsA("TextLabel") then continue end
        TableUtils.setInstance(desc, LeaderboardsUi[self.leaderboardObj.id].EntryStyle)
    end
end

function View:setScoreType()
    self.Score = SharedSherlock:find({"EzRef", "Get"}, {inst=self.leaderboard, refName="Score"})
    self.Score.Text = self.leaderboardObj.scoreType
end

function View:createEntryGuiObjs()
    self.LeaderboardFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=self.leaderboard, refName="LeaderboardFrame"})
    self.entryTemplate = SharedSherlock:find({"EzRef", "Get"}, {inst=self.leaderboard, refName="EntryTemplate"})
    local maxNumberEntries = self.leaderboardObj.leaderboardData.maxNumberEntries
	for i=1,maxNumberEntries do
		local frame = self.entryTemplate:Clone()
		frame.LayoutOrder = i

		local place = frame.Rank
		place.Text = tostring(i).."°"
		place.LayoutOrder = 0

		local player = frame.Player
		player.LayoutOrder = 1
		player.Text = ""

		local score = frame.Score
		score.LayoutOrder = 2
		score.Text = ""

		frame.Visible = false
		frame.Name = tostring(i)
		frame.Parent = self.LeaderboardFrame
	end
end

function View:renderEntries(entries)
    for i, entry in pairs(entries) do
        local frame = self.LeaderboardFrame[tostring(i)]
        local ok, playerName = pcall(function()
            return Players:GetNameFromUserIdAsync(entry.key)
        end)
        if ok then
            frame.Player.Text = playerName
        else
            frame.Player.Text = entry.key
        end
        local score = entry.value
        local isNaN = (score ~= score)
        if isNaN then
            frame.Score.Text = "NaN"
        else
            frame.Score.Text = NumberFormatter.numberToEng(score)
            if frame.Score.Text == "0" then
                frame.Visible = false
            else
                frame.Visible = true
            end
        end
    end
end

function View:Destroy()
    self._maid:Destroy()
end

return View