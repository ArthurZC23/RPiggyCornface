local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Gaia = Mod:find({"Gaia", "Server"})

local ClientRequests = {}
ClientRequests.__index = ClientRequests

function ClientRequests.new(playerGameSession)
    local self = {}
    setmetatable(self, ClientRequests)
    self.playerGameSession = playerGameSession
    self.player = playerGameSession.player

    self:createRemotes()

    self.handlers = {}
    self.handlerDbs = {}

    for _, child in ipairs(script:GetChildren()) do
        if not child:IsA("ModuleScript") then error ("Child must be module script.") end
        if child == script then continue end
        local scope = child.Name
        self.handlers[scope] = require(child)
        self.handlerDbs[scope] = {}
    end

    self.SetRequestGameSessionRF = self.player.Remotes.Functions.SetRequestGameSession

    self.SetRequestGameSessionRF.OnServerInvoke = function(plr, scope, action)
        if plr ~= self.player then return end
        self:handleRequest(scope, action)
    end

    return self
end

function ClientRequests:handleRequest(scope, action)
    local handler = self.handlers[scope]

    if handler and (not self.handlerDbs[scope][action.name]) then
        self.handlerDbs[scope][action.name] = true
        local ok, err = pcall(function()
            return handler[action.name](self.player, scope, action)
        end)
        self.handlerDbs[scope][action.name] = false
        if not ok then error(err) end
    end
end

function ClientRequests:createRemotes()
    Gaia.createRemotes(self.player, {
        functions={
            "SetRequestGameSession",
        },
    })
end

function ClientRequests:Destroy()

end

return ClientRequests