local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

-- Sherlock could make it easy to swap this for a mockup.
local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Promise = Mod:find({"Promise", "Promise"})

local Bindables
if RunService:IsClient() then
    Bindables = ReplicatedStorage.Bindables
else
    Bindables = ServerStorage.Bindables
end

local module = function(fn, ...)
    Promise.try(fn, ...)
        :catch(function(err)
            local errMsg = ("Promise FastSpawn\nError: %s"):format(tostring(err))
            if RunService:IsClient() then warn(errMsg) end
            local ReportErrorRF = Bindables.Functions:WaitForChild("ReportError")
            ReportErrorRF:Invoke(errMsg, "error")
        end)
end

return module