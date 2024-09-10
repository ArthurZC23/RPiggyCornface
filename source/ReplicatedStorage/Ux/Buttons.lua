local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Bach = Mod:find({"Bach", "Bach"})
local Debounce = Mod:find({"Debounce", "Debounce"})
local Platforms = Mod:find({"Platforms", "Platforms"})

local RootF = script:FindFirstAncestor("Ux")
local Utils = RootF.Utils
local Dilatation = require(Utils.Dilatation)

local function _onLeft(btn, btnSize, kwargs)
    return function()
        Dilatation.shrink(btn, btnSize)
	end
end

local function _onHover(btn, btnSize, kwargs)
    return function()
        Dilatation.expand(btn, btnSize, kwargs.dilatation)
        Bach:play("Hover", Bach.SoundTypes.SfxGui)
	end
end

local function _onClick(btn, kwargs)
    return function()
        Bach:play("Click", Bach.SoundTypes.SfxGui)
    end
end

local module = {}

-- kwargs allow for custom behavior
function module.addUx(btn, kwargs)
    local maid = Maid.new()
    kwargs = kwargs or {}
    local btnSize = btn.Size

    -- if Platforms.getPlatform() == Platforms.Platforms.Console then
    --     maid:Add(btn.SelectionLost:Connect(Debounce.standard(_onLeft(btn, btnSize, kwargs))))
    --     btn.SelectionGained:Connect(Debounce.standard(_onHover(btn, btnSize, kwargs)))
    -- else
    --     maid:Add(btn.MouseLeave:Connect(Debounce.standard(_onLeft(btn, btnSize, kwargs))))
    --     maid:Add(btn.MouseEnter:Connect(Debounce.standard(_onHover(btn, btnSize, kwargs))))
    -- end
    maid:Add(btn.MouseLeave:Connect(Debounce.standard(_onLeft(btn, btnSize, kwargs))))
    maid:Add(btn.MouseEnter:Connect(Debounce.standard(_onHover(btn, btnSize, kwargs))))
    maid:Add(btn.Activated:Connect(Debounce.standard(_onClick(btn, kwargs))))
    return maid
end

return module