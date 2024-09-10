local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local S = Data.Strings.Strings
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Promise = Mod:find({"Promise", "Promise"})
local GatherBugReport = Mod:find({"Bugs", "GatherBugReport"})
local TableUtils = Mod:find({"Table", "Utils"})

local DataStoreService = require(ServerStorage.DataStoreService)
local BugDS = DataStoreService:GetDataStore("Bug")

local PlayerBugReportS = {}
PlayerBugReportS.__index = PlayerBugReportS
PlayerBugReportS.className = "PlayerBugReport"
PlayerBugReportS.TAG_NAME = PlayerBugReportS.className

function PlayerBugReportS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerBugReportS)

    if not self:getFields() then return end
    self:createRemotes()
    self:setPlayerNetwork()
    -- self:handleBugReport()

    return self
end

-- function PlayerBugReportS:handleBugReport()
--     self.network:Connect(self.BugReportRE.OnServerEvent, function(player, bugId, bugClientData)
--         local data = {
--             bugId = bugId,
--             player = {
--                 userId = player.UserId,
--                 name = player.Name,
--             },
--             client = bugClientData,
--         }
--         local bugsData = Data.Bugs.Bugs.bugs
--         local bugCb = GatherBugReport.cbs[bugsData[bugId].name]
--         local char = self.playerState.player.Character
--         if not (char and char.Parent) then return end
--         local charState = binderCharState:getObj(char)
--         if not charState then return end
--         local charMovement = binderCharMovement:getObj(char)
--         if not charMovement then return end

--         local bugReport = bugCb({
--             playerState = self.playerState,
--             charState = charState,
--             charMovement = charMovement,
--         })

--         data.server = bugReport
--         local _saveCb = function()
--             return Promise.new(function(resolve, reject)
--                 local ok, err = pcall(function()
--                     BugDS:UpdateAsync(bugId, function(bugData)
--                         bugData = bugData or {}
--                         if #bugsData > 1e3 then return end
--                         table.insert(bugData, data)
--                         return bugData
--                     end)
--                 end)
--                 if ok then
--                     resolve()
--                 else
--                     reject(err)
--                 end
--             end)
--         end
--         if RunService:IsStudio() then
--             print(("Bug Report:\n%s"):format(TableUtils.stringify(data)))
--         end
--         Promise.retryWithDelay(_saveCb, 3, 10)
--     end)
-- end

function PlayerBugReportS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

function PlayerBugReportS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"BugReport"},
        functions = {},
    }))
end

function PlayerBugReportS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=1
    })
end

function PlayerBugReportS:Destroy()
    self._maid:Destroy()
end

return PlayerBugReportS