local module = {}

function module.cleanup(task)
    if type(task) == "function" then
        task()
    elseif typeof(task) == "RBXScriptConnection" then
        task:Disconnect()
    elseif task.Destroy then
        task:Destroy()
    elseif task.cleanup then
        task:cleanup()
    end
end

return module