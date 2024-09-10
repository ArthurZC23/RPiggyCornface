local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Bach = Mod:find({"Bach", "Bach"})
local Debounce = Mod:find({"Debounce", "Debounce"})
local Platforms = Mod:find({"Platforms", "Platforms"})

local function _onClick(btn, kwargs)
    return function()
        Bach:play("Click", Bach.SoundTypes.SfxGui)
    end
end

local module = {}

-- kwargs allow for custom behavior
function module.addUx(btn, kwargs)
    kwargs = kwargs or {}
    btn.Activated:Connect(Debounce.standard(_onClick(btn, kwargs)))
end

return module