local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

return {
    Name = "getStateScopeC";
	Aliases = {"get"};
	Description = "Get Client State Scope for the player.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "Target player.";
		},
		{
			Type = "stateTypeClient";
			Name = "stateType";
			Description = "State type."
		},
        {
			Type = "storesScopes # sessionScopes $ localSessionScopes";
			Name = "scope";
			Description = "State scope."
		}
	},
    ClientRun = function(context, player, stateType, scope)
        local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
        local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=player})
        if not playerState then return ("Player %s is not on this server"):format(player.Name) end

        local state = playerState:get(stateType, scope)
        TableUtils.print(state)
        return "Done"

	end
}