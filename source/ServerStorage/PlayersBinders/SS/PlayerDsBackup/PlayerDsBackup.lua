local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local Promise = Mod:find({"Promise", "Promise"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})
local S = Data.Strings.Strings
local TimeUnits = Data.Date.TimeUnits

local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local DataStoreService = require(ServerStorage.DataStoreService)

local PlayerDsBackup = {}
PlayerDsBackup.__index = PlayerDsBackup
PlayerDsBackup.className = "PlayerDsBackup"
PlayerDsBackup.TAG_NAME = PlayerDsBackup.className

function PlayerDsBackup.new(player)
    local self = {}
    setmetatable(self, PlayerDsBackup)
    self._maid = Maid.new()
    self.player = player
    self.backupDs = DataStoreService:GetDataStore("Backup")
    FastSpawn(self.runBackup, self)
    return self
end

function PlayerDsBackup:runBackup()
    -- Make backup when player join
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=self.player})
    if not playerState then return end

    -- Only make and remove backups if state is valid.
    if playerState:isStateBackup() then return end

    -- Promise will cancel if player leaves and playerState will not error.
    self._maid:Add(
        Promise.defer(function (resolve, reject)
        local ok, backupMetadata = pcall(function() return self:updateBackupMetadata() end)
        if ok then
            resolve(backupMetadata)
        else
            local err = backupMetadata
            reject(tostring(err))
        end
        end),
        "cancel"
    )
    :andThen(function (backupMetadata)
        local ok, err = self:writeNewBackup(backupMetadata)
        if ok then
            return backupMetadata
        else
            error(tostring(err))
        end
    end)
        :andThen(function (backupMetadata)
        local ok, err = self:updateDsMetadata(backupMetadata)
        if not ok then error(tostring(err)) end
    end)
    :catch(function (err)
        ErrorReport.report(
            self.player.UserId,
            ("%s PlayerDsBackup had an error. Error: %s"):format(self.player.UserId, tostring(err)),
            ErrorReport.severity.error
        )
    end)
end

function PlayerDsBackup:updateBackupMetadata()
    local key = ("%s/%s"):format(self.player.UserId, "last")
    local metadata = self.backupDs:GetAsync(key)

    if metadata then
        metadata.idx = metadata.idx + 1
    else
        metadata = {}
        metadata.idx = 1
    end

    local datetime = DateTime.fromUnixTimestamp(Cronos:getTime())
    metadata.datetime = datetime:ToIsoDate()

    return metadata
end

function PlayerDsBackup:updateDsMetadata(backupMetadata)
    local ok, err = pcall(function()
        local key = ("%s/%s"):format(self.player.UserId, "last")
        self.backupDs:SetAsync(key, backupMetadata)
    end)
    return ok, err
end

function PlayerDsBackup:writeNewBackup(backupMetadata)
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=self.player})
    if not playerState then
        return false, "PlayerState not found."
    end

    local storeState = playerState:getStoresStateCopy()

    local ok, err = pcall(function()
        local key = ("%s/%s"):format(self.player.UserId, backupMetadata.idx)
        self.backupDs:SetAsync(key, storeState)
    end)

    return ok, err
end

function PlayerDsBackup:Destroy()
    self._maid:Destroy()
end

return PlayerDsBackup