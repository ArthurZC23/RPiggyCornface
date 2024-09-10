local ServerStorage = game:GetService("ServerStorage")

local RootF = script:FindFirstAncestor("Cmdr")

--Cmdr is a package outside VSC
local Cmdr = require(ServerStorage.Tp.Cmdr)

task.spawn(function()
    Cmdr:RegisterHooksIn(RootF.SS.Hooks)
    Cmdr:RegisterDefaultCommands() -- This loads the default set of commands that Cmdr comes with. (Optional)
    Cmdr:RegisterTypesIn(RootF.SS.Types) -- Register my types
    Cmdr:RegisterCommandsIn(RootF.SS.GenericCommands) -- Register commands from your own folder. (Optional)
    Cmdr:RegisterCommandsIn(RootF.SS.Commands) -- Register commands from your own folder. (Optional)
end)

local module = {}

return module