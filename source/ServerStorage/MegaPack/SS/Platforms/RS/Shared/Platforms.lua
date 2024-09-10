local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})

local platforms = {
	Console="Console",
	Mobile="Mobile",
	Desktop="Desktop",
}

local module = {}

module.Platforms = Mts.makeEnum("Platforms", platforms)

function module._getPlatform()
    if UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
        module.platform = module.Platforms.Desktop
    elseif UserInputService.TouchEnabled then
        module.platform = module.Platforms.Mobile
    elseif UserInputService.GamepadEnabled then
        module.platform = module.Platforms.Console
    end

	-- if GuiService:IsTenFootInterface() and not UserInputService.MouseEnabled then
    --     module.platform = module.Platforms.Console
	-- elseif
    --     (UserInputService.TouchEnabled and not UserInputService.MouseEnabled)
    --     or UserInputService.TouchEnabled and RunService:IsStudio()
    -- then
    --     module.platform = module.Platforms.Mobile
	-- else
    --     module.platform = module.Platforms.Desktop
	-- end
    return module.platform
end

function module.getPlatform()
    local Data = Mod:find({"Data", "Data"})
    local StudioData = Data.Studio.Studio
    local studioPlatform = StudioData.platform.platform
    if RunService:IsStudio() and studioPlatform then
        warn(("getPlatform returns %s in Studio."):format(studioPlatform))
        return studioPlatform
    end
    return module.platform
end
module.platform = module._getPlatform()

setmetatable(module, {__index = module.Platforms})

return module