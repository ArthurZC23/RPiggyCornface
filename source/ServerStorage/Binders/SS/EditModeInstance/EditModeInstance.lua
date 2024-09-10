local EditModeInstance = {}
EditModeInstance.__index = EditModeInstance
EditModeInstance.className = "EditModeInstance"
EditModeInstance.TAG_NAME = EditModeInstance.className

function EditModeInstance.new(inst)
    inst.Parent = nil
    task.defer(function()
        inst:Destroy()
    end)
    return
end

function EditModeInstance:Destroy()

end

return EditModeInstance