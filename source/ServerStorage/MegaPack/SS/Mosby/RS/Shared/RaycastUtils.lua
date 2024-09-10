local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Maid = Mod:find({"Maid"})

local AssetsRS = ReplicatedStorage.Assets
local APart = AssetsRS.Parts.Basic.APart

local module = {}

do
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    raycastParams.IgnoreWater = true

    function module.getFloor(p0, kwargs)
        kwargs = kwargs or {}
        local distance = kwargs.distance or 100
        raycastParams.FilterDescendantsInstances = {CollectionService:GetTagged("MapBlock")}
        local ray = workspace:Raycast(p0, distance * (-Vector3.yAxis), raycastParams)
        if ray then
            return ray.Instance, ray
        end
    end

    function module.showP0AndP1(p0, dir)
        local maid = Maid.new()
        local props = {
            CanCollide = false,
            Color = Color3.fromRGB(255, 0, 0),
            Name = "Raycast",
            Parent = workspace.Tmp,
        }
        local p0Block = maid:Add(GaiaShared.clone(APart, props))
        p0Block.Position = p0
        p0Block.Name = "RaycastP0"
        print(p0Block:GetFullName())

        local p1 = p0 + dir
        local p1Block = maid:Add(GaiaShared.clone(APart, props))
        p1Block.Position = p1
        p1Block.Name = "RaycastP1"
        print(p1Block:GetFullName())

        return maid
    end
end

return module