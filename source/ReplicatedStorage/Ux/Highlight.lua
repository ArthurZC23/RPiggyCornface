local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Bach = Mod:find({"Bach", "Bach"})
local Debounce = Mod:find({"Debounce", "Debounce"})
local Platforms = Mod:find({"Platforms", "Platforms"})

local function _onLeft(imageBtn, kwargs)
    imageBtn.ImageColor3 = kwargs.colors.default
    return function()
        imageBtn.ImageColor3 = kwargs.colors.default
	end
end

local function _onHover(imageBtn, kwargs)
    return function()
		imageBtn.ImageColor3 = kwargs.colors.hover
        Bach:play("Hover", Bach.SoundTypes.SfxGui)
	end
end

local function _onClick()
    return function()
        Bach:play("Click", Bach.SoundTypes.SfxGui)
    end
end

local module = {}

function module.addUx(kwargs)
    kwargs = kwargs or {}
    local hoverTarget = kwargs.hoverGui
    local activateGui = kwargs.activateGui
    -- if Platforms.getPlatform() == Platforms.Platforms.Console then
    --     hoverTarget.SelectionLost:Connect(Debounce.standard(_onLeft(hoverTarget, kwargs)))
    --     hoverTarget.SelectionGained:Connect(Debounce.standard(_onHover(hoverTarget, kwargs)))
    -- else
    --     hoverTarget.MouseLeave:Connect(Debounce.standard(_onLeft(hoverTarget, kwargs)))
    --     hoverTarget.MouseEnter:Connect(Debounce.standard(_onHover(hoverTarget, kwargs)))
    -- end
    hoverTarget.MouseLeave:Connect(Debounce.standard(_onLeft(hoverTarget, kwargs)))
    hoverTarget.MouseEnter:Connect(Debounce.standard(_onHover(hoverTarget, kwargs)))
    activateGui.Activated:Connect(Debounce.standard(_onClick()))
end

return module