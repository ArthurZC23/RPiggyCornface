local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Debounce = Mod:find({"Debounce", "Debounce"})
local Bach = Mod:find({"Bach", "Bach"})
local Maid = Mod:find({"Maid"})

local Sounds = {}
Sounds.__index = Sounds

function Sounds.new(guiObj, sfxs)
    local self = {}
    setmetatable(self, Sounds)
	self.guiObj = guiObj
	sfxs = sfxs or {}
    self.sfxs = {
        click = sfxs.click or "Click",
        hover = sfxs.hover or "Hover",
    }
    self._maid = Maid.new()
    self._maid:Add(
        guiObj.MouseEnter:Connect(
            function ()
                self:onEntered()
            end
        )
    )
    self._maid:Add(
		guiObj.Activated:Connect(
			Debounce.standard(
				function ()
					self:onActivated()
				end
			)
        )
    )
    return self
end

function Sounds:onEntered()
	Bach:playAsync(self.sfxs.hover, Bach.SoundTypes.SfxGui)
end

function Sounds:onActivated()
	Bach:playAsync(self.sfxs.click, Bach.SoundTypes.SfxGui)
end

function Sounds:Destroy()
    self._maid:Destroy()
end

return Sounds