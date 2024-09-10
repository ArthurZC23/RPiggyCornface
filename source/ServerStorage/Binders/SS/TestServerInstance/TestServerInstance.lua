local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local ServerTypesData = Data.Game.ServerTypes

local TestServerInstance = {}
TestServerInstance.__index = TestServerInstance
TestServerInstance.className = "TestServerInstance"
TestServerInstance.TAG_NAME = TestServerInstance.className

function TestServerInstance.new(inst)
    local envs = {
        [ServerTypesData.sTypes.StudioNotPublished] = true,
        [ServerTypesData.sTypes.StudioPublishedPrivate] = true,
        [ServerTypesData.sTypes.StudioPublishedTest] = true,
        [ServerTypesData.sTypes.LivePrivate] = true,
        [ServerTypesData.sTypes.LiveTest] = true,
    }

    if (not envs[ServerTypesData.ServerType]) then
        task.defer(function()
            inst:Destroy()
        end)
    end

    return
end

function TestServerInstance:Destroy()

end

return TestServerInstance