local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local CasEffects = Mod:find({"UserInput", "CasEffects"})
local Promise = Mod:find({"Promise", "Promise"})
local Maid = Mod:find({"Maid"})

local module = {}

function module.ValidateNumTaps(func, targetTapCount, maxInterval, kwargs)
    local tapCount = 0
    local maid = Maid.new()
	return function(actionName, inputState, inputObject)
        tapCount += 1
        maid:Add2(Promise.delay(maxInterval):andThen(function() tapCount = 0 end), "ResetTapCount")
        if targetTapCount == tapCount then
            return func(actionName, inputState, inputObject, kwargs)
        end
        return Enum.ContextActionResult.Pass
    end
end

function module.InputBegin(func, kwargs)
	return function(actionName, inputState, inputObject)
        if inputState == Enum.UserInputState.Begin then
            local result = func(actionName, inputState, inputObject, kwargs)
            task.spawn(CasEffects.applyEffect, actionName, inputState, inputObject, kwargs)
			return result
		end
		return Enum.ContextActionResult.Pass
    end
end

function module.InputEnd(func, kwargs)
	return function(actionName, inputState, inputObject)
        if inputState == Enum.UserInputState.End then
            local result = func(actionName, inputState, inputObject, kwargs)
            task.spawn(CasEffects.applyEffect, actionName, inputState, inputObject, kwargs)
			return result
		end
		return Enum.ContextActionResult.Pass
    end
end

function module.InputChange(func, kwargs)
	return function(actionName, inputState, inputObject)
        if inputState == Enum.UserInputState.Change then
            local result = func(actionName, inputState, inputObject, kwargs)
            task.spawn(CasEffects.applyEffect, actionName, inputState, inputObject, kwargs)
			return result
		end
		return Enum.ContextActionResult.Pass
    end
end

function module.InputCancel(func, kwargs)
	return function(actionName, inputState, inputObject)
        if inputState == Enum.UserInputState.Cancel then
            local result = func(actionName, inputState, inputObject, kwargs)
            task.spawn(CasEffects.applyEffect, actionName, inputState, inputObject, kwargs)
			return result
		end
		return Enum.ContextActionResult.Pass
    end
end

function module.generic(handlersByInputState, kwargs)
    local handlers = {}
    for inputState, handler in pairs(handlersByInputState) do
        handlers[inputState] = handler
    end
	return function(actionName, inputState, inputObject)
        if handlers[inputState] then
            local result = handlers[inputState](actionName, inputState, inputObject, kwargs)
            task.spawn(CasEffects.applyEffect, actionName, inputState, inputObject, kwargs)
			return result
        end
		return Enum.ContextActionResult.Pass
    end
end

function module.BindAction(contextAction, callback, hasBtn, inputs)
    CasEffects.addActionTable(contextAction)
    ContextActionService:BindAction(
        contextAction,
        callback,
        hasBtn,
        unpack(inputs)
    )
end

function module.UnbindAction(contextAction)
    CasEffects.removeAllActionEffects(contextAction)
    ContextActionService:UnbindAction(contextAction)
end

return module