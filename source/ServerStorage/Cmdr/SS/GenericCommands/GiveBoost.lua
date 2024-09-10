return {
    Name = "giveBoost";
	Aliases = {"giveBoost"};
	Description = "Give Boost. Super User Only.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "Target player.";
		},
        {
			Type = "string";
			Name = "id";
			Description = "Boost id.";
		},
        {
			Type = "number";
			Name = "duration";
			Description = "Boost duration.";
		},
	}
}