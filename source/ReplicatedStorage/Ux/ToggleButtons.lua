local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Bach = Mod:find({"Bach", "Bach"})
local Debounce = Mod:find({"Debounce", "Debounce"})
local Platforms = Mod:find({"Platforms", "Platforms"})

local RootF = script:FindFirstAncestor("Ux")
local Utils = RootF.Utils
local Dilatation = require(Utils.Dilatation)

local function _onLeft(btns, btnSize, kwargs)
    return function()
        for _, btn in ipairs(btns) do
            Dilatation.shrink(btn, btnSize)
        end
	end
end

local function _onHover(btns, btnSize, kwargs)
    return function()
        for _, btn in ipairs(btns) do
            Dilatation.expand(btn, btnSize, kwargs.dilatation)
        end
        Bach:play("Hover", Bach.SoundTypes.SfxGui)
	end
end

local function _onClick(btn, kwargs)
    return function()
        Bach:play("Click", Bach.SoundTypes.SfxGui)
    end
end

local module = {}

function module.addUx(btns, kwargs)
    local btnSize = btns[1].Size
    for _, btn in ipairs(btns) do
        -- if Platforms.getPlatform() == Platforms.Platforms.Console then
        --     btn.SelectionLost:Connect(Debounce.standard(_onLeft(btns, btnSize, kwargs)))
        --     btn.SelectionGained:Connect(Debounce.standard(_onHover(btns, btnSize, kwargs)))
        -- else
        --     btn.MouseLeave:Connect(Debounce.standard(_onLeft(btns, btnSize, kwargs)))
        --     btn.MouseEnter:Connect(Debounce.standard(_onHover(btns, btnSize, kwargs)))
        -- end
        btn.MouseLeave:Connect(Debounce.standard(_onLeft(btns, btnSize, kwargs)))
        btn.MouseEnter:Connect(Debounce.standard(_onHover(btns, btnSize, kwargs)))
        btn.Activated:Connect(Debounce.standard(_onClick(btn, kwargs)))
    end
end

return module