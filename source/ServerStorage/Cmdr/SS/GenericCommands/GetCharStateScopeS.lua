return {
    Name = "getCharStateScopeS";
	Aliases = {"get"};
	Description = "Get Server Char State Scope for the player.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "Target player.";
		},
		{
			Type = "stateTypeServer";
			Name = "stateType";
			Description = "State type."
		},
        {
			Type = "string";
			Name = "scope";
			Description = "State scope."
		}
	}
}