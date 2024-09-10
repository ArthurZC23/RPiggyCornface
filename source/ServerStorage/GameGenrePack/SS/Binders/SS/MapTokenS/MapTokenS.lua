local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local MapTokenS = {}
MapTokenS.__index = MapTokenS
MapTokenS.className = "MapToken"
MapTokenS.TAG_NAME = MapTokenS.className

MapTokenS.bag = {}

function MapTokenS.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, MapTokenS)

    if not self:getFields() then return end
    self:addObjToBag()
    self:setFx()
    self:addClickDetector()

    return self
end

local GaiaShared = Mod:find({"Gaia", "Shared"})
function MapTokenS:setFx()
    -- GaiaShared.create("Highlight", {
    --     DepthMode = Enum.HighlightDepthMode.Occluded,
    --     FillColor = Color3.fromRGB(251, 255, 19),
    --     Parent = self.RootModel,
    -- })
    GaiaShared.create("SelectionBox", {
        Color3 = Color3.fromRGB(41, 172, 34),
        LineThickness = 0.05,
        SurfaceColor3 = Color3.fromRGB(41, 172, 34),
        SurfaceTransparency = 0.8,
        Adornee = self.RootModel,
        Parent = self.RootModel,
    })
end

function MapTokenS:addObjToBag()
    if MapTokenS.bag[self.tokenId] then
        warn(("Repeated %s"):format(self.tokenId))
    end
    MapTokenS.bag[self.tokenId] = self
end

local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})
local TableUtils = Mod:find({"Table", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
function MapTokenS:addClickDetector()
    self.clickDetector = self._maid:Add(GaiaShared.create("ClickDetector", {
        MaxActivationDistance = 20,
        Parent = self.RootModel,
    }))
    self._maid:Add(self.clickDetector.MouseClick:Connect(function(player)
        local playerState = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "PlayerState", inst = player})
        if not playerState then return end

        local mapTokenState = playerState:get(S.Session, "MapTokens")
        if mapTokenState.st[self.tokenId] then return end

        local numTokens = TableUtils.len(mapTokenState.st)

        local char = player.Character
        if not (char and char.Parent) then return end
        if char:HasTag("Monster") then return end

        do
            local action = {
                name = "add",
                id = self.tokenId,
                ux = true,
            }
            playerState:set(S.Session, "MapTokens", action)
        end
        self:sendNotification(player, numTokens)
    end))
end

local Sampler = Mod:find({"Math", "Sampler"})
function MapTokenS:sendNotification(player, numTokens)
    local texts
    local sampler = Sampler.new()
    local totalTokens = Data.Map.Map.numberTokens
    if numTokens < 0.3 * totalTokens then
        texts = {
            "Nice work",
            "Well done",
        }
    elseif numTokens < 0.6 * totalTokens then
        texts = {
            "Don't stop now",
            "Keep going",
        }
    elseif numTokens < totalTokens then
        texts = {
            "Just a few more",
            "Almost there",
        }
    else
        texts = {
            "Go back to the house",
        }
    end
    local Text = sampler:sampleArray(texts)
    NotificationStreamRE:FireClient(player,
        {
            Text = Text,
        },
        {
            Root = "Tokens",
            lifetime = 6,
        }
    )
end

function MapTokenS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.tokenId = self.RootModel:GetAttribute("tokenId")
            if not self.tokenId then return end

            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootModel.Parent
        end,
    })
    return ok
end

function MapTokenS:Destroy()
    self._maid:Destroy()
end

return MapTokenS