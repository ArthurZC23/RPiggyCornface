local RunService = game:GetService("RunService")

local DeleteOnClientC = {}
DeleteOnClientC.__index = DeleteOnClientC
DeleteOnClientC.className = "DeleteOnClient"
DeleteOnClientC.TAG_NAME = DeleteOnClientC.className

function DeleteOnClientC.new(inst)
    task.defer(function()
        inst:Destroy()
    end)
    return
end

function DeleteOnClientC:Destroy()

end

return DeleteOnClientC