local ServerStorage = game:GetService("ServerStorage")
local Data = ServerStorage.Data.SS.Data
local Obby = require(Data.Obby.Obby:Clone())

local APartProto = workspace.Studio.BaseParts.APart:Clone()

local numStairs = 50 * Obby.colorPaletteQty
local stairHeight = 1
local stairWidth = 16
local stairLength = 2

local omega = 0.1
local radius = 20

local function spiral(n)
    local p0 = Vector3.new(
        radius * math.cos(omega * n),
        stairHeight * n,
        radius * math.sin(omega * n)
    )
    local p1 = Vector3.new(
        - omega * radius * math.sin(omega * n),
        0,
        omega * radius * math.cos(omega * n)
    )
    return CFrame.lookAt(p0, p0 + p1)
end

APartProto.Size = Vector3.new(stairWidth, stairHeight, stairLength)
local StairModel = Instance.new("Model")
StairModel.Name = "Stair"
StairModel:PivotTo(CFrame.new(0, 0, 0))

for i = 1, numStairs do
    local stair = APartProto:Clone()
    local cssId = tostring(((i - 1) % Obby.colorPaletteQty) + 1)
    stair:SetAttribute("CSSClass", cssId)
    local cf = spiral(i)
    stair:PivotTo(cf)
    stair.Parent = StairModel
    if i == 1 then
        StairModel.PrimaryPart = stair
    end
end

StairModel.Parent = workspace.Tmp


-- Obby Large


-- local numStairs = 21 * Obby.colorPaletteQty
-- local stairHeight = 1
-- local stairWidth = 16
-- local stairLength = 2

-- local omega = 0.05
-- local radius = 30

-- Game icon

-- local numStairs = 50 * Obby.colorPaletteQty
-- local stairHeight = 1
-- local stairWidth = 16
-- local stairLength = 2

-- local omega = 0.1
-- local radius = 20

-- Close together

-- local omega = 0.1
-- local radius = 10

-- local omega = 0.05
-- local radius = 30
