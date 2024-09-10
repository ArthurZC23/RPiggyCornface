local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)

local module = {}

local GetActionsCodecRF = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Functions", "GetActionsCodec"})

local Codec = GetActionsCodecRF:InvokeServer()

function module.encode(stateManager, stateType, scope, actionName)
    return Codec.encoder[stateManager][stateType][scope][actionName]
end

function module.decode(code)
    return Codec.decoder[code]
end

return module