return {
    Name = "getGameStateScopeS";
	Aliases = {"getG"};
	Description = "Get Game Server State Scope.";
	Group = "DefaultAdmin";
	Args = {
        {
			Type = "gameSessionScopes";
			Name = "scope";
			Description = "State scope."
		}
	}
}