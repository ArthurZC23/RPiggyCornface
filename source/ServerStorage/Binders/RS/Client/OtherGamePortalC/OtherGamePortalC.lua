local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local LocalDebounce = Mod:find({"Debounce", "Local"})
local Data = Mod:find({"Data", "Data"})

local OtherGamePortalC = {}
OtherGamePortalC.__index = OtherGamePortalC
OtherGamePortalC.className = "OtherGamePortal"
OtherGamePortalC.TAG_NAME = OtherGamePortalC.className

function OtherGamePortalC.new(rootModel)
    local self = {
        rootModel = rootModel,
        _maid = Maid.new(),
        Toucher = rootModel.Skeleton.Toucher,
    }
    setmetatable(self, OtherGamePortalC)

    self.Toucher.Touched:Connect(LocalDebounce.playerLimbExecutionCooldown(
        function() self:showTeleportGui() end,
        1,
        "Hrp"
    ))

    return self
end

function OtherGamePortalC:showTeleportGui()
    local openBtnLikeEvent = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal="TeleportToOtherGameBtn"})
    openBtnLikeEvent:Fire(true, {
        gameName = self.rootModel:GetAttribute("GameName"),
    })
end

function OtherGamePortalC:Destroy()
    self._maid:Destroy()
end

return OtherGamePortalC