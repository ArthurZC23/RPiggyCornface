local RunService = game:GetService("RunService")

local StudioInstance = {}
StudioInstance.__index = StudioInstance
StudioInstance.className = "StudioInstance"
StudioInstance.TAG_NAME = StudioInstance.className

function StudioInstance.new(inst)
    if not RunService:IsStudio() then
        inst.Parent = nil
        task.defer(function()
            inst:Destroy()
        end)
    end
    return
end

function StudioInstance:Destroy()

end

return StudioInstance