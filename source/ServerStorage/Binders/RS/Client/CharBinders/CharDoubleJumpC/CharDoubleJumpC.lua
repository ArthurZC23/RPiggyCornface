local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Debounce = Mod:find({"Debounce", "Debounce"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local localPlayer = Players.LocalPlayer
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=localPlayer})

local CharDoubleJumpS = {}
CharDoubleJumpS.__index = CharDoubleJumpS
CharDoubleJumpS.className = "CharDoubleJump"
CharDoubleJumpS.TAG_NAME = CharDoubleJumpS.className

local TIME_BETWEEN_JUMPS = 0.25
local IN_AIR_JUMP_POWER_MULTIPLIER = 1

function CharDoubleJumpS.new(char)
    if char.Name ~= localPlayer.Name then return end

    local self = {
        _maid = Maid.new(),
        char = char,
        numJumps = 0,
        totalJumps = 2,
        jumpPower = 50,
    }
    setmetatable(self, CharDoubleJumpS)
    if not self:getFields() then return end

    self._maid:Add(self.charParts.humanoid.StateChanged:Connect(function (old, new)
        self:requestToResetNumJumps(old, new)
    end))

    self._maid:Add(UserInputService.JumpRequest:Connect(Debounce.cooldown(
        function() self:onJumpRequest() end,
        TIME_BETWEEN_JUMPS
    )))

    return self
end

function CharDoubleJumpS:requestToResetNumJumps(old, new)
    if new == Enum.HumanoidStateType.Landed then
        self.charParts.humanoid.JumpPower = self.jumpPower
        self.numJumps = 0
    end
end

function CharDoubleJumpS:onJumpRequest()
    if self.charParts.humanoid:GetState() == Enum.HumanoidStateType.Dead then return end
    if self.numJumps >= self.totalJumps then return end
    self.numJumps = self.numJumps + 1

    if self.numJumps == 1 then
        self.charParts.humanoid.JumpPower = self.jumpPower
    else
        self.charParts.humanoid.JumpPower = self.jumpPower * IN_AIR_JUMP_POWER_MULTIPLIER
        self.charParts.humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

function CharDoubleJumpS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerState", localPlayer},
                {"CharState", self.char},
                {"CharParts", self.char},
                {"CharProps", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {
  
            }
            local root
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function CharDoubleJumpS:Destroy()
    self._maid:Destroy()

end

return CharDoubleJumpS