local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local JobScheduler = Mod:find({"DataStructures", "JobScheduler"})
local Gaia = Mod:find({"Gaia", "Server"})
local Queue = Mod:find({"DataStructures", "Queue"})
local Promise = Mod:find({"Promise", "Promise"})
local Data = Mod:find({"Data", "Data"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})
local LeaderboardData = Data.Leaderboards.Leaderboards
local LeaderboardCodec = require(ServerStorage.Leaderboard.SS.LeaderboardCodec)
local Maid = Mod:find({"Maid"})

local RootF = script:FindFirstAncestor("LeaderboardS")
local View = require(RootF:WaitForChild("View"))

local ONE_MINUTE = 60
-- if RunService:IsStudio() then ONE_MINUTE = 10 end

local Leaderboard = {}
Leaderboard.__index = Leaderboard
Leaderboard.className = "Leaderboard"
Leaderboard.TAG_NAME = Leaderboard.className

function Leaderboard.new(leaderboard)
	if not leaderboard:FindFirstAncestorOfClass("Workspace") then return end
	local self = {
        leaderboard = leaderboard,
        id = leaderboard:GetAttribute("LeaderboardId"),
        _maid = Maid.new()
    }
    assert(self.id, ("Leaderboard %s doens't have id."):format(leaderboard:GetFullName()))

	setmetatable(self, Leaderboard)

    self.leaderboardData = LeaderboardData[self.id]
	self.scoreType = self.leaderboardData.scoreType
    self.timeType = self.leaderboardData.timeType

    self:createRemotes()

    self.view = self._maid:Add(View.new(self))
    self.entries = {}

	self.ODataStore = self.leaderboardData.ODataStore

    self.scheduler = JobScheduler.new(
        function() self:update() end,
        "cooldown",
        {
            queueProps = {
                {},
                {
                    maxSize=1,
                    fullQueueHandler=Queue.FullQueueHandlers.DiscardNew,
                    queueType=Queue.QueueTypes.FirstLastIdxs,
                }
            },
            schedulerProps = {
                cooldownFunc = function() return ONE_MINUTE end
            }
        }
    )

    self.UpdateRE.OnServerEvent:Connect(function() self.scheduler:pushJob({}) end)

	return self
end


function Leaderboard:createRemotes()
    local screen = self.leaderboard:FindFirstAncestorWhichIsA("BasePart")
    self.UpdateRE = ComposedKey.getFirstDescendant(screen, {"Remotes", "Events", "Update"})
    if not self.UpdateRE then
        Gaia.createRemotes(screen, {
            events = {"Update"}
        })
    end
    self.UpdateRE = screen.Remotes.Events.Update
end

function Leaderboard:getData()
	return Promise.try(function()
		local data = self.ODataStore:GetSortedAsync(false, self.leaderboardData.maxNumberEntries)
		return data
	end)
end

function Leaderboard:addEntry(i, entry)
    local compressedScore = entry.value
    local score = LeaderboardCodec.decode(compressedScore)
    self.entries[i] = {key = entry.key, value = score}
end

function Leaderboard:update()
    -- print("Update Leaderboard on server")
	self:getData()
		:andThen(function(pages)
			local firstPage = pages:GetCurrentPage()
            self.entries = {}
			for i, entry in ipairs(firstPage) do
                self:addEntry(i, entry)
            end
            self.view:renderEntries(self.entries)
		end)
		:catch(function(err)
            ErrorReport.report("Server", tostring(err), "error")
		end)
end

function Leaderboard:Destroy()
    self._maid:Destroy()
end


return Leaderboard