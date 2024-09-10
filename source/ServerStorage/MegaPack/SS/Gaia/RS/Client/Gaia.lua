local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TmpF = ReplicatedStorage.Gaia.Tmp

local Gaia = {}

local RFunctions = ReplicatedStorage.Remotes.Functions
local RequestInstanceRF = RFunctions:WaitForChild("GaiaRequestInstance")
local DeleteTmpInstanceRF = RFunctions:WaitForChild("GaiaDeleteTmpInstance")

function Gaia.requestInstance(instId, kwargs)
    local id = RequestInstanceRF:InvokeServer(instId, kwargs)
    local inst = TmpF[id]
    inst.Parent = nil
    DeleteTmpInstanceRF:InvokeServer(id)
    return inst
end

return Gaia