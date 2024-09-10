local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Debounce = Mod:find({"Debounce", "Debounce"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local Data = Mod:find({"Data", "Data"})
local ErrorReportData = Data.ErrorReport.ErrorReport

local Bindables = ServerStorage.Bindables
local BindableFunctions = Bindables.Functions

GaiaServer.createRemotes(ReplicatedStorage, {
    events = {
        "LogErrorReport",
        "MethodErrorReport",
    },
})

GaiaShared.create("BindableFunction", {
    Name = "ReportError",
    Parent = BindableFunctions,
})

local RootF = script:FindFirstAncestor("ErrorReport")
local ErrorReport = require(RootF.SS.ErrorReport)

local LogErrorReportRE = ReplicatedStorage.Remotes.Events.LogErrorReport
LogErrorReportRE.OnServerEvent:Connect(Debounce.remotesCooldownPerPlayer(
    ErrorReport.reportFromClient, ErrorReportData.Client.cooldown)
)

local MethodErrorReportRE = ReplicatedStorage.Remotes.Events.MethodErrorReport
MethodErrorReportRE.OnServerEvent:Connect(Debounce.remotesCooldownPerPlayer(
    ErrorReport.reportFromClient, ErrorReportData.Client.cooldown)
)

local ReportErrorRF = BindableFunctions.ReportError
ReportErrorRF.OnInvoke = function(message, severity)
    ErrorReport.report(nil, message, severity)
end

local module = {}

return module