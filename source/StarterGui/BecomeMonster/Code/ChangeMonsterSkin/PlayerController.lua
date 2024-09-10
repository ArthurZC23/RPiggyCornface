local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Data = Mod:find({"Data", "Data"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local S = Data.Strings.Strings

local localPlayer = Players.LocalPlayer

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")

local RootF = script:FindFirstAncestor("ChangeMonsterSkin")
local View = require(ComposedKey.getAsync(RootF, {"PlayerView"}))

local Controller = {}
Controller.__index = Controller
Controller.className = "ChangeMonsterSkinController"

function Controller.new(playerGuis)
    local self = {
        _maid = Maid.new(),
        playerGuis = playerGuis,
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end
    self.view = self._maid:Add(View.new(self))

    return self
end

function Controller:setMonsterSkin(btn, skinId)
    local maid = Maid.new()

    maid:Add(btn.Activated:Connect(function()
        local monsterSkins = Data.MonsterSkins.MonsterSkins.idData[skinId]
        local shopData = monsterSkins.rewards.shop
        local mSkinState = self.playerState:get(S.Stores, "MonsterSkins")
        if
            mSkinState.st[skinId]
            or shopData._type == "Group"
            or shopData._type == "Gamepass"
        then
            local ChangeSkinRE = ComposedKey.getEvent(localPlayer, "ChangeSkin")
            if not ChangeSkinRE then return end
            ChangeSkinRE:FireServer(skinId)
            do
                local action = {
                    name = "viewTab",
                    tabName = "BecomeMonster",
                }
                self.playerState:set(S.LocalSession, "BecomeMonsterGui", action)
            end
        elseif shopData._type == "Money" then
            local PurchaseSkinRE = ComposedKey.getEvent(localPlayer, "PurchaseSkin")
            if not PurchaseSkinRE then return end
            PurchaseSkinRE:FireServer(skinId)
        end
    end))

    return maid
end

function Controller:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerState", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {
                "TeleportToOtherGame",
            }
            local root = localPlayer
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return gui.Parent
        end,
        cooldown=1
    })
    return ok
end

function Controller:Destroy()
    self._maid:Destroy()
end

return Controller