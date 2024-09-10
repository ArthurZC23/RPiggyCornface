local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local GaiaServer = Mod:find({"Gaia", "Server"})

local ActionsLoader = Mod:find({"StateManager", "Actions", "Loader"})
local GameSessionActions = ActionsLoader.load(ReplicatedStorage.Actions.Game.Session.Actions)
local PlayerStateSessionActions = ActionsLoader.load(ReplicatedStorage.Actions.Player.Session.Actions)
local PlayerStateStoresActions = ActionsLoader.load(ReplicatedStorage.Actions.Player.Stores.Actions)
local CharStateSessionActions = ActionsLoader.load(ReplicatedStorage.Actions.Char.Session.Actions)

GaiaServer.createRemotes(ReplicatedStorage, {
    functions = {"GetActionsCodec"},
})
local GetActionsCodecRF = ReplicatedStorage.Remotes.Functions.GetActionsCodec

local module = {}

local function loadCodec()
    local actionsPerStateTypePerStateManager = {
        PlayerGameState = {
            Session = GameSessionActions.actions,
        },
        PlayerState = {
            Session = PlayerStateSessionActions.actions,
            Stores = PlayerStateStoresActions.actions,
        },
        CharState = {
            Session = CharStateSessionActions.actions,
        },
    }

    local encoder = {}
    local decoder = {}
    local lastCode = 0

    for stateManager, actionsPerStateType in pairs(actionsPerStateTypePerStateManager) do
        encoder[stateManager] = {}
        for stateType, actions in pairs(actionsPerStateType) do
            encoder[stateManager][stateType] = {}
            for scope, scopeActions in pairs(actions) do
                encoder[stateManager][stateType][scope] = {}
                for actionName in pairs(scopeActions) do
                    encoder[stateManager][stateType][scope][actionName] = tostring(lastCode)
                    decoder[tostring(lastCode)] = {stateManager, stateType, scope, actionName}
                    lastCode += 1
                end
            end
        end
    end

    return {
        encoder=encoder,
        decoder=decoder,
    }
end
local Codec = loadCodec()

function module.encode(stateManager, stateType, scope, actionName)
    return Codec.encoder[stateManager][stateType][scope][actionName]
end

function module.decode(code)
    return Codec.decoder[code]
end

GetActionsCodecRF.OnServerInvoke = function(player)
    return Codec
end

return module