return {
    Name = "setMapTokens";
	Aliases = {"setMapTokens"};
	Description = "Set Map Tokens. Super User Only.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "Target player.";
		},
        {
			Type = "number";
			Name = "value";
			Description = "Number tokens.";
		},
	}
}