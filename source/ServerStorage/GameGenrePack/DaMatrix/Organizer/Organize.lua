local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RootF = script:FindFirstAncestor("GameGenrePack")

local RS = RootF.RS
RS.Name = "GameGenrePack"
RS.Parent = ReplicatedStorage

local ClientLoader = RootF.DaMatrix.ClientLoader
ClientLoader.Name = "Loader"
ClientLoader.Parent = RS.Client

-- Every package need a loading module, even if it's nil.
-- GameGenrePack has packages which the game should not have access to the code.
-- ErrorReport fall into that category
local SS = RootF.SS
for _, packageRootFolder in ipairs(SS:GetChildren()) do
    local daMatrix = packageRootFolder.DaMatrix
    local Organizer = daMatrix:FindFirstChild("Organizer")
    -- Some packages, like error report need to be distributed.
    if Organizer then require(Organizer.Organize) end
end

local module = {}

return module