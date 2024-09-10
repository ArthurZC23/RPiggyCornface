local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Gaia = Mod:find({"Gaia", "Shared"})

local Bindables = ReplicatedStorage.Bindables
local BindableFunctions = Bindables.Functions

local RootF = script:FindFirstAncestor("ErrorReport")
local ErrorReport = require(RootF:WaitForChild("Client"):WaitForChild("ErrorReport"))

Gaia.create("BindableFunction", {
    Name = "ReportError",
    Parent = BindableFunctions,
})

local ReportErrorRF = BindableFunctions.ReportError
ReportErrorRF.OnInvoke = function(message, severity)
    ErrorReport.report(message, severity)
end

local module = {}

return module