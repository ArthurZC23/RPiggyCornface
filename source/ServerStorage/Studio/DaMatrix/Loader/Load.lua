local RootFolder = script:FindFirstAncestor("Studio")

local handleStudio = require(RootFolder.SS.HandleStudio)
task.defer(handleStudio.excludeStudioInstances)

local module = {}

return module
