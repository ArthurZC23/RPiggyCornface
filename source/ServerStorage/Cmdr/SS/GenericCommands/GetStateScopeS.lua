return {
    Name = "getStateScopeS";
	Aliases = {"get"};
	Description = "Get Server State Scope for the player.";
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