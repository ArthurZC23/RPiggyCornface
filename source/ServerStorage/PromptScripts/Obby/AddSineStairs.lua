local ServerStorage = game:GetService("ServerStorage")
local Data = ServerStorage.Data.SS.Data
local Obby = require(Data.Obby.Obby:Clone())

local APartProto = workspace.Studio.BaseParts.APart:Clone()

local numStairs = 21 * Obby.colorPaletteQty
local stairHeight = 1
local stairWidth = 16
local stairLength = 2

local amplitude = 10
local omega = 0.1

local function spiral(n)
    local p0 = Vector3.new(
        0,
        amplitude * math.sin(omega * n),
        stairLength * n
    )
    local p1 = Vector3.new(
        0,
        0,
        stairLength
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
